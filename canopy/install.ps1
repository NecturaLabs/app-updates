# canopy-installer (this marker line identifies the script; keep it)
#
# Installs, upgrades or removes Canopy for the current Windows user, without administrator rights:
#
#   irm https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.ps1 | iex
#
# With options (here: uninstall), run the downloaded text as a script block:
#
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.ps1))) -Uninstall
#
# The script reads the update manifest in NecturaLabs/app-updates (canopy/latest.json, or
# canopy/beta.json), downloads the Windows archive over HTTPS only (every redirect is checked),
# checks its SHA-256 against the manifest and refuses anything that does not match. It never runs
# what it downloads and never installs git.
#
# Layout: everything lives in %LOCALAPPDATA%\Programs\Canopy (CANOPY_INSTALL_DIR overrides it):
#   canopy.exe  README.md  LICENSE  legal\  VERSION  uninstall.ps1  .canopy-install (receipt)
# Outside it, only: a Start Menu shortcut, an "Apps & features" entry under
# HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\io.necturalabs.Canopy, and the folder
# on the user PATH (-NoPath skips it).
#
# Works in Windows PowerShell 5.1 and PowerShell 7, and stays ASCII-only (5.1 reads a file
# without a byte order mark in the ANSI code page). The source is packaging/install.ps1 in
# NecturaLabs/Canopy; the release workflow publishes it to NecturaLabs/app-updates/canopy/.
param(
    # Install the newest build, including beta builds (the beta channel).
    [switch]$Beta,
    # Install this build number (for example 412) instead of the newest one.
    [string]$Version = '',
    # Do not add the install folder to the user PATH.
    [switch]$NoPath,
    # Remove Canopy: exactly what this script created. Settings and data stay.
    [switch]$Uninstall,
    # With -Uninstall: also delete Canopy's settings, saved hosting tokens (tokens.json),
    # logs and caches (asks first).
    [switch]$Purge,
    # Do not ask for confirmation (for -Purge).
    [switch]$Yes,
    # Show the help.
    [switch]$Help
)

# Everything else runs in this script block's own child scope, so that through `irm | iex` (which
# runs the text in the caller's scope) StrictMode, the preference variables, the helpers and the
# installer's variables never reach the caller's session. Anything else on the command line (a
# mistyped option) arrives as -ExtraArgs and is refused. A download cut short leaves this block
# unclosed, which PowerShell refuses to parse, so nothing runs.
& {
    param([object[]]$ExtraArgs = @(), $Invocation = $null)

    Set-StrictMode -Version 2.0
    $ErrorActionPreference = 'Stop'
    $ExtraArgs = @($ExtraArgs | Where-Object { $null -ne $_ })
    # Windows PowerShell 5.1 renders a progress bar per downloaded chunk, which slows downloads.
    $ProgressPreference = 'SilentlyContinue'

    # The script file when run as one (-File, or the installed uninstall.ps1); empty when the text
    # was piped into iex or run as a script block, where `exit` would close the user's PowerShell.
    $ScriptFile = ''
    if ($null -ne $Invocation -and $Invocation.MyCommand.CommandType -eq 'ExternalScript') { $ScriptFile = $Invocation.MyCommand.Path }

    $AppId = 'io.necturalabs.Canopy'
    $FeedUrl = 'https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy'
    $ReleasesUrl = 'https://github.com/NecturaLabs/app-updates/releases/download'
    $UninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppId"
    # The loopback test feed (CANOPY_INSTALL_BASE_URL), when set: plain HTTP to exactly this host
    # and port, and nowhere else.
    $LocalHost = ''
    $LocalPort = 0
    # What the installer puts in its folder; uninstall removes these and nothing else.
    $InstalledEntries = @('canopy.exe', 'README.md', 'LICENSE', 'legal', 'VERSION', 'uninstall.ps1', '.canopy-install')

    # -------------------------------------------------------------------------------------------
    # Canopy's user data, removed only by -Purge. Keep this list in step with the app (and with
    # packaging/install.sh); the contract is in packaging/README.md ("Canopy's data folders").
    #   vendor  a vendor-specific name: deleted when it is a folder.
    #   eframe  the folder eframe::storage_dir("canopy") gives today: deleted only when it holds
    #           .canopy-data or Canopy's own files (Test-EframeCanopy).
    function Get-PurgeTargets {
        @(
            @{ Kind = 'eframe'; Path = (Join-Path $env:APPDATA 'canopy\data') },
            @{ Kind = 'vendor'; Path = (Join-Path $env:APPDATA 'NecturaLabs\Canopy') },
            @{ Kind = 'vendor'; Path = (Join-Path $env:LOCALAPPDATA 'NecturaLabs\Canopy') }
        )
    }

    function Test-EframeCanopy([string]$Dir) {
        if (Test-Path -LiteralPath (Join-Path $Dir 'tokens.json') -PathType Leaf) { return $true }
        $ron = Join-Path $Dir 'app.ron'
        if ((Test-Path -LiteralPath $ron -PathType Leaf) -and (Select-String -LiteralPath $ron -SimpleMatch 'canopy-settings-v1' -Quiet)) { return $true }
        foreach ($sub in @(@('logs', 'canopy-*.jsonl'), @('crashes', 'crash-*.txt'))) {
            $d = Join-Path $Dir $sub[0]
            if ((Test-Path -LiteralPath $d -PathType Container) -and @(Get-ChildItem -LiteralPath $d -Filter $sub[1] -File -Force).Count -gt 0) { return $true }
        }
        return $false
    }
    # -------------------------------------------------------------------------------------------

    # The installer's own errors are ApplicationExceptions, which nothing else here throws, so
    # they can be told apart from unexpected failures.
    function Fail([string]$Message) { throw (New-Object System.ApplicationException $Message) }
    function Say([string]$Message = '') { Write-Host $Message }
    function Warn([string]$Message) { Write-Host "warning: $Message" -ForegroundColor Yellow }

    function Show-Usage {
        Say @'
Install Canopy for the current user (no administrator rights).

  irm https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.ps1 | iex

With options:

  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.ps1))) [options]
  powershell -ExecutionPolicy Bypass -File install.ps1 [options]

Options:
  -Beta         Install the newest build, including beta builds (the beta channel).
  -Version N    Install build N (for example 412) instead of the newest one; also the way
                to go back to an older build.
  -NoPath       Do not add the install folder to the user PATH.
  -Uninstall    Remove Canopy: exactly what this script created. Settings and data stay.
  -Purge        With -Uninstall: also delete Canopy's settings, saved hosting tokens
                (tokens.json), logs and caches (asks first).
  -Yes          Do not ask for confirmation (for -Purge).
  -Help         Show this help.

Environment:
  CANOPY_INSTALL_DIR   Install folder (default %LOCALAPPDATA%\Programs\Canopy).

"Apps & features" (or the installed uninstall.ps1) also uninstalls. Re-running the installer
upgrades in place; a failed upgrade keeps the installed build. It never replaces a newer
installed build with an older one unless -Version asks for it.
'@
    }

    # -------------------------------------------------------------------------------------------
    # Helpers

    function Test-LocalFeedUri([Uri]$Uri) {
        return ($LocalHost -ne '' -and $Uri.Scheme -ceq 'http' -and $Uri.Host -eq $LocalHost -and
            $Uri.Port -eq $LocalPort -and $Uri.UserInfo -eq '')
    }

    # Downloads $Url to $OutFile. HTTPS only, and redirects are followed here, one by one, so each
    # is checked to stay on HTTPS: Windows PowerShell 5.1 would follow one to plain HTTP. Plain
    # HTTP only to the loopback test feed, which is never redirected. Network and HTTP errors are
    # thrown as they come (not as ApplicationExceptions), so callers can tell them apart.
    function Get-File([string]$Url, [string]$OutFile) {
        $uri = [Uri]$Url
        for ($hop = 0; $hop -le 5; $hop++) {
            $local = Test-LocalFeedUri $uri
            if (-not $local -and -not ($uri.Scheme -ceq 'https' -and $uri.UserInfo -eq '')) {
                Fail "refusing to download from $uri (HTTPS only)"
            }
            $request = [Net.WebRequest]::Create($uri)
            $request.AllowAutoRedirect = $false
            $request.Timeout = 60000
            $request.ReadWriteTimeout = 60000
            $request.UserAgent = 'canopy-installer'
            if ($local) { $request.Proxy = $null }
            $response = $null
            try {
                $response = $request.GetResponse()
            } catch {
                # A 3xx can arrive as a WebException that carries the response.
                $e = $_.Exception
                while ($null -ne $e -and -not ($e -is [Net.WebException])) { $e = $e.InnerException }
                if ($null -eq $e) { throw }
                if ($null -eq $e.Response) { throw $e.Message }
                $code = [int]$e.Response.StatusCode
                if ($code -lt 300 -or $code -ge 400) { $e.Response.Close(); throw $e.Message }
                $response = $e.Response
            }
            try {
                $code = [int]$response.StatusCode
                if ($code -ge 300 -and $code -lt 400) {
                    if ($local) { Fail "the test feed redirected $uri" }
                    $location = $response.Headers['Location']
                    if (-not $location) { Fail "a redirect without a target from $uri" }
                    $uri = New-Object System.Uri -ArgumentList @($uri, [string]$location)
                    continue
                }
                if ($code -lt 200 -or $code -ge 300) { throw "HTTP $code from $uri" }
                $in = $response.GetResponseStream()
                $out = [IO.File]::Create($OutFile)
                try { $in.CopyTo($out) } finally { $out.Dispose(); $in.Dispose() }
                return
            } finally {
                $response.Close()
            }
        }
        Fail "too many redirects from $Url"
    }

    # A build number: one to nine digits, no leading zero. Builds are ordered by this integer alone.
    function Test-Build([string]$V) {
        return $V -cmatch '^[1-9][0-9]{0,8}\z'
    }

    # "build 412" for a build number; anything else (such as the 0.2.0-beta.1 of an installation
    # made before builds were numbered) as it is. Such a value is older than every build.
    function Get-BuildLabel([string]$V) {
        if (Test-Build $V) { return "build $V" }
        return $V
    }

    # The manifest of channel $Name, or $null when that channel has none (beta only).
    function Get-Channel([string]$Name, [string]$Work) {
        $file = Join-Path $Work "$Name.json"
        try {
            Get-File "$FeedUrl/$Name.json" $file
        } catch [System.ApplicationException] {
            throw
        } catch {
            if ($Name -eq 'beta') { return $null }
            Fail "could not read the update manifest $FeedUrl/$Name.json: $($_.Exception.Message)"
        }
        $m = Get-Content -LiteralPath $file -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not (Test-Build ([string]$m.version))) {
            # A manifest from before builds were numbered is older than any build: the beta
            # channel is then treated as not published.
            if ($Name -eq 'beta') { return $null }
            Fail "the update manifest $Name.json names no valid build number"
        }
        return $m
    }

    function Get-Platform($Manifest, [string]$Key) {
        $platforms = $Manifest.PSObject.Properties['platforms']
        if ($null -eq $platforms -or $null -eq $platforms.Value) { return $null }
        $p = $platforms.Value.PSObject.Properties[$Key]
        if ($null -eq $p) { return $null }
        return $p.Value
    }

    function Confirm-Action([string]$Question) {
        if ($Yes) { return $true }
        try {
            $answer = Read-Host "$Question [y/N]"
        } catch {
            Fail "$($Question): cannot ask in this session; re-run with -Yes to confirm"
        }
        return $answer -match '^(y|yes)\z'
    }

    function Test-CanopyRunning([string]$Root) {
        $exe = Join-Path $Root 'canopy.exe'
        $running = Get-Process -Name canopy -ErrorAction SilentlyContinue | Where-Object {
            try { $_.Path -eq $exe } catch { $false }
        }
        return [bool]$running
    }

    function Read-Receipt([string]$Root) {
        $r = @{}
        $file = Join-Path $Root '.canopy-install'
        if (Test-Path -LiteralPath $file) {
            foreach ($line in Get-Content -LiteralPath $file) {
                if ($line -match '^([a-z_]+)=(.*)\z') { $r[$Matches[1]] = $Matches[2] }
            }
        }
        return $r
    }

    function Write-Receipt([string]$Root, [hashtable]$Values) {
        $lines = @("# Written by the Canopy installer: what it created outside $Root.")
        foreach ($k in ($Values.Keys | Sort-Object)) { $lines += "$k=$($Values[$k])" }
        Set-Content -LiteralPath (Join-Path $Root '.canopy-install') -Value $lines -Encoding UTF8
    }

    # The user PATH as stored (unexpanded), so entries such as %USERPROFILE%\bin survive.
    function Get-UserPath {
        $key = Get-Item -LiteralPath 'HKCU:\Environment'
        return [string]$key.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    }

    function Set-UserPath([string]$Value) {
        if ($Value -eq '') {
            Remove-ItemProperty -LiteralPath 'HKCU:\Environment' -Name Path -ErrorAction SilentlyContinue
        } else {
            Set-ItemProperty -LiteralPath 'HKCU:\Environment' -Name Path -Value $Value -Type ExpandString
        }
        # Setting a user variable through .NET broadcasts WM_SETTINGCHANGE, so Explorer and new
        # terminals see the new PATH without signing out.
        [Environment]::SetEnvironmentVariable('CANOPY_INSTALLER_REFRESH', '1', 'User')
        [Environment]::SetEnvironmentVariable('CANOPY_INSTALLER_REFRESH', $null, 'User')
    }

    function Test-PathHas([string]$PathValue, [string]$Dir) {
        foreach ($p in ($PathValue -split ';')) {
            if ($p.TrimEnd('\') -ieq $Dir.TrimEnd('\')) { return $true }
        }
        return $false
    }

    function Remove-FromUserPath([string]$Dir) {
        $current = Get-UserPath
        if (-not (Test-PathHas $current $Dir)) { return }
        $kept = @($current -split ';' | Where-Object { $_ -ne '' -and $_.TrimEnd('\') -ine $Dir.TrimEnd('\') })
        Set-UserPath ($kept -join ';')
        Say "  removed $Dir from the user PATH"
    }

    function Get-StartMenuShortcut {
        return Join-Path ([Environment]::GetFolderPath('Programs')) 'Canopy.lnk'
    }

    function Get-ShortcutTarget([string]$Lnk) {
        if (-not (Test-Path -LiteralPath $Lnk)) { return $null }
        $shell = New-Object -ComObject WScript.Shell
        return $shell.CreateShortcut($Lnk).TargetPath
    }

    # The Apps & features entry's InstallLocation, or $null when there is no entry.
    function Get-UninstallKeyLocation {
        if (-not (Test-Path -LiteralPath $UninstallKey)) { return $null }
        $props = Get-ItemProperty -LiteralPath $UninstallKey -ErrorAction SilentlyContinue
        if ($props -and $props.PSObject.Properties['InstallLocation']) { return [string]$props.InstallLocation }
        return ''
    }

    function Test-ReparsePoint([string]$Path) {
        $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
        return ($null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint))
    }

    function Show-GitReport {
        # Windows PowerShell 5.1 turns a native command's stderr into errors, which 'Stop' would
        # make fatal: git prints to stderr when git-lfs is missing.
        $ErrorActionPreference = 'Continue'
        Say ''
        $git = Get-Command git -ErrorAction SilentlyContinue
        $lfs = $false
        if ($git) {
            try { Say ('git:      ' + (& git --version 2>$null)) } catch { Say 'git:      found' }
            try {
                $lfsVersion = & git lfs version 2>$null
                if ($LASTEXITCODE -eq 0 -and $lfsVersion) { $lfs = $true; Say "git-lfs:  $lfsVersion" }
            } catch { $lfs = $false }
        } else {
            Say 'git:      NOT FOUND. Canopy needs git 2.30 or newer on PATH.'
        }
        if (-not $lfs) { Say 'git-lfs:  not found (only needed for repositories that use Git LFS)' }
        if (-not $git -or -not $lfs) {
            Say '          Install Git for Windows (it includes Git LFS): winget install --id Git.Git -e'
            Say '          or download it from https://git-scm.com/download/win'
            Say '          (this installer never installs git for you).'
        }
    }

    # Takes the install lock, shared by install and uninstall; returns its path.
    function Lock-Install([string]$Root) {
        $lock = Join-Path $Root '.lock'
        try {
            [void](New-Item -ItemType Directory -Path $lock -ErrorAction Stop)
        } catch {
            Fail "another Canopy install or uninstall is running (remove $lock if it is not)"
        }
        return $lock
    }

    # -------------------------------------------------------------------------------------------
    # Uninstall

    # What -Purge does with target $T: 'delete', 'keep' (it exists but is not recognisably
    # Canopy's), or '' when it does not exist. A symlink or junction is never followed.
    function Get-PurgeVerdict($T) {
        if (-not (Test-Path -LiteralPath $T.Path)) { return '' }
        if (Test-ReparsePoint $T.Path) { return 'keep' }
        if (-not (Test-Path -LiteralPath $T.Path -PathType Container)) { return 'keep' }
        if ($T.Kind -eq 'vendor' -or (Test-Path -LiteralPath (Join-Path $T.Path '.canopy-data') -PathType Leaf)) { return 'delete' }
        if ($T.Kind -eq 'eframe' -and (Test-EframeCanopy $T.Path)) { return 'delete' }
        return 'keep'
    }

    function Invoke-ConfirmPurge {
        $delete = @()
        $keep = @()
        foreach ($t in Get-PurgeTargets) {
            switch (Get-PurgeVerdict $t) {
                'delete' { $delete += $t.Path }
                'keep' { $keep += $t.Path }
            }
        }
        if ($keep.Count -gt 0) {
            Say "-Purge leaves these: each has a generic name and no .canopy-data marker file, or is a"
            Say "link, so it may belong to another program. Check them, and remove them by hand if they are Canopy's:"
            foreach ($d in $keep) { Say "  $d" }
        }
        if ($delete.Count -eq 0) {
            Say 'No Canopy settings or data found to purge.'
            return $false
        }
        Say "-Purge deletes Canopy's settings, saved hosting tokens (tokens.json), logs and caches:"
        foreach ($d in $delete) { Say "  $d" }
        if (Confirm-Action 'Delete them?') { return $true }
        Say 'Keeping them.'
        return $false
    }

    function Invoke-Purge([bool]$Confirmed) {
        if ($Confirmed) {
            foreach ($t in Get-PurgeTargets) {
                # Checked again: only what was listed and still qualifies goes.
                if ((Get-PurgeVerdict $t) -eq 'delete') {
                    Remove-Item -LiteralPath $t.Path -Recurse -Force
                    Say "  removed $($t.Path)"
                }
            }
            # The parents, only when that left them empty.
            foreach ($parent in @((Join-Path $env:APPDATA 'canopy'), (Join-Path $env:APPDATA 'NecturaLabs'), (Join-Path $env:LOCALAPPDATA 'NecturaLabs'))) {
                if ((Test-Path -LiteralPath $parent -PathType Container) -and -not (Test-ReparsePoint $parent) -and -not (Get-ChildItem -LiteralPath $parent -Force)) {
                    Remove-Item -LiteralPath $parent -Force
                }
            }
        }
        Say ''
        Say "Tokens saved in Settings -> Accounts stay in Windows Credential Manager (service"
        Say "`"$AppId`"): remove them in Canopy before uninstalling, or in Credential Manager."
    }

    function Invoke-Uninstall([string]$Root) {
        $purgeOk = $false
        if ($Purge) { $purgeOk = Invoke-ConfirmPurge }
        if (-not (Test-Path -LiteralPath $Root)) {
            Say "Canopy is not installed in $Root; nothing to remove."
        } else {
            if (-not (Test-Path -LiteralPath (Join-Path $Root '.canopy-install'))) {
                Fail "$Root has no .canopy-install receipt, so this script did not create it; not touching it"
            }
            if (Test-CanopyRunning $Root) { Fail 'Canopy is running; close it and run the uninstaller again' }
            $lock = Lock-Install $Root
            try {
                Say "Removing Canopy from $Root"
                $receipt = Read-Receipt $Root
                $exe = Join-Path $Root 'canopy.exe'
                $lnk = Get-StartMenuShortcut
                if ((Get-ShortcutTarget $lnk) -eq $exe) {
                    Remove-Item -LiteralPath $lnk -Force
                    Say "  removed $lnk"
                }
                if ((Get-UninstallKeyLocation) -eq $Root) {
                    Remove-Item -LiteralPath $UninstallKey -Recurse -Force
                    Say '  removed the Apps & features entry'
                }
                if ($receipt.ContainsKey('path') -and $receipt['path'] -eq '1') { Remove-FromUserPath $Root }
                foreach ($name in $InstalledEntries) {
                    $p = Join-Path $Root $name
                    if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Recurse -Force }
                }
                # Leftovers of an interrupted install.
                Get-ChildItem -LiteralPath $Root -Force | Where-Object { $_.Name -like '.staging.*' -or $_.Name -like '.previous.*' } |
                    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
            } finally {
                Remove-Item -LiteralPath $lock -Force -ErrorAction SilentlyContinue
            }
            $left = @(Get-ChildItem -LiteralPath $Root -Force)
            if ($left.Count -eq 0) {
                Remove-Item -LiteralPath $Root -Force
                Say "  removed $Root"
            } else {
                Warn "$Root holds files the installer did not put there, so it was kept with them:"
                foreach ($e in $left) { Say "  $($e.FullName)" }
            }
        }
        if ($Purge) {
            Invoke-Purge $purgeOk
        } else {
            Say 'Settings and data were kept (-Uninstall -Purge removes them).'
        }
    }

    # -------------------------------------------------------------------------------------------
    # Install

    # Copies this script to $Dest (the uninstaller is the installer run as uninstall.ps1).
    function Save-Self([string]$Dest) {
        $self = $ScriptFile
        if ($self -and (Test-Path -LiteralPath $self) -and ((Get-Content -LiteralPath $self -TotalCount 1) -match '^# canopy-installer')) {
            Copy-Item -LiteralPath $self -Destination $Dest -Force
            return
        }
        # Run through iex: fetch the published copy of this script again.
        try {
            Get-File "$FeedUrl/install.ps1" $Dest
            $first = Get-Content -LiteralPath $Dest -TotalCount 1
            $errors = $null
            [void][System.Management.Automation.Language.Parser]::ParseFile($Dest, [ref]$null, [ref]$errors)
            if ($first -notmatch '^# canopy-installer' -or $errors.Count -gt 0) { throw 'not the installer' }
        } catch {
            Warn 'could not save uninstall.ps1; uninstall from Apps & features or with the installer and -Uninstall'
            Remove-Item -LiteralPath $Dest -Force -ErrorAction SilentlyContinue
        }
    }

    function Move-Entries([string]$From, [string]$To) {
        foreach ($e in @(Get-ChildItem -LiteralPath $From -Force | Where-Object { -not $_.Name.StartsWith('.') })) {
            Move-Item -LiteralPath $e.FullName -Destination (Join-Path $To $e.Name)
        }
    }

    # Puts the previous version back after a failed or interrupted swap. In phase 'in' it first
    # removes the entries that came from the staging folder ($Staged; by then every old entry is
    # aside). It never deletes an old entry and never moves one over an existing name. Returns
    # $false when something could not be put back; the rest stays in $Previous.
    function Undo-Swap([string]$Root, [string]$Previous, [string]$Phase, [string[]]$Staged) {
        $ok = $true
        if ($Phase -eq 'in') {
            foreach ($name in $Staged) {
                $p = Join-Path $Root $name
                if (Test-Path -LiteralPath $p) {
                    try { Remove-Item -LiteralPath $p -Recurse -Force } catch { $ok = $false }
                }
            }
        }
        foreach ($e in @(Get-ChildItem -LiteralPath $Previous -Force)) {
            $dest = Join-Path $Root $e.Name
            if (Test-Path -LiteralPath $dest) { $ok = $false; continue }
            try { Move-Item -LiteralPath $e.FullName -Destination $dest } catch { $ok = $false }
        }
        if ($ok) { Remove-Item -LiteralPath $Previous -Force -ErrorAction SilentlyContinue }
        return $ok
    }

    function Invoke-Install([string]$Root) {
        if (-not [Environment]::Is64BitOperatingSystem) { Fail 'Canopy needs 64-bit Windows' }
        $arch = $env:PROCESSOR_ARCHITEW6432
        if (-not $arch) { $arch = $env:PROCESSOR_ARCHITECTURE }
        $key = 'windows-x86_64'
        $target = 'x86_64-pc-windows-msvc'
        if ($arch -eq 'ARM64') { Say 'Windows on Arm: installing the x64 build, which Windows runs through emulation.' }
        Say "Installing Canopy for Windows ($key)"

        if ((Test-Path -LiteralPath $Root) -and -not (Test-Path -LiteralPath $Root -PathType Container)) {
            Fail "$Root exists and is not a folder"
        }
        $receiptFile = Join-Path $Root '.canopy-install'
        if ((Test-Path -LiteralPath $Root) -and -not (Test-Path -LiteralPath $receiptFile) -and (Get-ChildItem -LiteralPath $Root -Force)) {
            Fail "$Root is not empty and was not created by this installer; choose another CANOPY_INSTALL_DIR"
        }
        # The folders this creates, deepest first: a failed first install removes exactly those,
        # and only while they are empty.
        $createdDirs = @()
        if (-not (Test-Path -LiteralPath $Root)) {
            $d = $Root
            while ($d -and -not (Test-Path -LiteralPath $d)) { $createdDirs += $d; $d = Split-Path -Parent $d }
            [void][IO.Directory]::CreateDirectory($Root)
        }
        $lock = $null
        $work = Join-Path $Root ('.staging.' + [IO.Path]::GetRandomFileName())
        $previous = ''
        $phase = ''
        $staged = @()
        $succeeded = $false
        try {
            $lock = Lock-Install $Root
            New-Item -ItemType Directory -Path $work | Out-Null
            $oldVersion = ''
            $versionFile = Join-Path $Root 'VERSION'
            if ((Test-Path -LiteralPath $receiptFile) -and (Test-Path -LiteralPath $versionFile)) { $oldVersion = [string](Get-Content -LiteralPath $versionFile -TotalCount 1) }
            $oldVersion = $oldVersion.Trim()

            # Which release.
            $pin = $Version.Trim()
            if ($pin -and -not (Test-Build $pin)) { Fail "-Version $pin is not a build number like 412" }
            Say 'Reading the update manifest'
            $use = Get-Channel 'latest' $work
            if ($Beta -or $pin) {
                $betaManifest = Get-Channel 'beta' $work
                if ($betaManifest) {
                    if ($pin) {
                        if ($betaManifest.version -eq $pin) { $use = $betaManifest }
                    } elseif (([long][string]$betaManifest.version) -gt ([long][string]$use.version)) {
                        $use = $betaManifest
                    }
                }
            }
            if (-not $pin -or $pin -eq $use.version) {
                $ver = [string]$use.version
                # Never a silent downgrade: an older version only when -Version asks for it.
                if (-not $pin -and (Test-Build $oldVersion) -and ([long]$oldVersion -gt [long]$ver)) {
                    $channel = if ($Beta) { 'beta' } else { 'stable' }
                    Fail ("Canopy build $oldVersion is installed, which is newer than build $ver, the newest on the $channel channel; nothing was changed.`n" +
                        "  To keep getting beta builds, run the installer with -Beta.`n" +
                        "  To install build $ver anyway, run it with -Version $ver.")
                }
                $p = Get-Platform $use $key
                if ($null -eq $p) {
                    $keys = @()
                    if ($use.PSObject.Properties['platforms'] -and $use.platforms) { $keys = @($use.platforms.PSObject.Properties | ForEach-Object { $_.Name }) }
                    $list = if ($keys.Count) { $keys -join ', ' } else { 'none' }
                    Fail "Canopy build $ver has no archive for Windows ($key) yet. Archives in this build: $list"
                }
                $url = [string]$p.url
                $sha = [string]$p.sha256
                $asset = $url.Substring($url.LastIndexOf('/') + 1)
            } else {
                $ver = $pin
                $asset = "canopy-build-$ver-$target.zip"
                Say "Reading the checksums of Canopy build $ver"
                $sums = Join-Path $work 'SHA256SUMS'
                try { Get-File "$ReleasesUrl/canopy-build-$ver/SHA256SUMS" $sums } catch [System.ApplicationException] { throw } catch {
                    Fail "Canopy build $ver is not published (no $ReleasesUrl/canopy-build-$ver/SHA256SUMS)"
                }
                $sha = ''
                foreach ($line in Get-Content -LiteralPath $sums) {
                    $parts = $line -split '\s+', 2
                    if ($parts.Count -eq 2 -and $parts[1].TrimStart('*') -eq $asset) { $sha = $parts[0]; break }
                }
                if (-not $sha) { Fail "Canopy build $ver has no archive for Windows ($key)" }
                $url = "$ReleasesUrl/canopy-build-$ver/$asset"
            }
            # Only ever download Canopy's own archive from Canopy's own release in the feed repository.
            if ($url -cne "$ReleasesUrl/canopy-build-$ver/$asset") { Fail "the manifest points outside Canopy's releases: $url" }
            if ($asset -cne "canopy-build-$ver-$target.zip") { Fail "unexpected archive name in the manifest: $asset" }
            if ($sha -cnotmatch '^[0-9a-f]{64}\z') { Fail "the manifest has no valid sha256 for $asset" }

            # Download and verify.
            Say "Downloading $url"
            $zip = Join-Path $work $asset
            try { Get-File $url $zip } catch [System.ApplicationException] { throw } catch { Fail "download failed: $url ($($_.Exception.Message))" }
            $got = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($got -ne $sha) {
                Fail "checksum mismatch for $asset`n  expected $sha`n  got      $got`nNothing was installed. Try again later; if it persists, report it."
            }
            Say "Checksum verified (sha256 $got)"
            $x = Join-Path $work 'x'
            Expand-Archive -LiteralPath $zip -DestinationPath $x
            $src = Join-Path $x "canopy-build-$ver-$target"
            if (-not (Test-Path -LiteralPath (Join-Path $src 'canopy.exe'))) { Fail "$asset has no canopy-build-$ver-$target\canopy.exe" }

            # Stage the new folder content.
            $new = Join-Path $work 'new'
            New-Item -ItemType Directory -Path $new | Out-Null
            foreach ($name in @('canopy.exe', 'README.md', 'LICENSE', 'legal')) {
                $from = Join-Path $src $name
                if (Test-Path -LiteralPath $from) { Copy-Item -LiteralPath $from -Destination (Join-Path $new $name) -Recurse }
            }
            Set-Content -LiteralPath (Join-Path $new 'VERSION') -Value $ver -Encoding ASCII
            Save-Self (Join-Path $new 'uninstall.ps1')
            $staged = @(Get-ChildItem -LiteralPath $new -Force | ForEach-Object { $_.Name })

            # Swap in two phases: 'aside' moves the old entries into .previous.*, 'in' moves the
            # staged ones into place. A failure (catch) or an interrupt (finally) undoes exactly
            # the phase reached.
            if (Test-CanopyRunning $Root) { Fail 'Canopy is running; close it and run the installer again' }
            $previous = Join-Path $Root ('.previous.' + [IO.Path]::GetRandomFileName())
            New-Item -ItemType Directory -Path $previous | Out-Null
            try {
                $phase = 'aside'
                Move-Entries $Root $previous
                $phase = 'in'
                Move-Entries $new $Root
                $phase = ''
            } catch {
                $why = $_.Exception.Message
                $restored = Undo-Swap $Root $previous $phase $staged
                $phase = ''
                if ($restored) { Fail "could not move the new version into $Root; the previous one was kept ($why)" }
                Fail "could not install the new version, nor put all of the previous one back ($why). Its remaining files are in $previous; move them back into $Root, or run the installer again."
            }
            $succeeded = $true
            # The folder is Canopy's from here on: claim it with a receipt at once.
            $receipt = Read-Receipt $Root
            $receipt['root'] = $Root
            $receipt['version'] = $ver
            Write-Receipt $Root $receipt
            # This swap's old version, and leftovers of an upgrade whose old canopy.exe was in use.
            Get-ChildItem -LiteralPath $Root -Force -Filter '.previous.*' | ForEach-Object {
                Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }

            # Register: Start Menu shortcut, Apps & features entry, user PATH. Each only where it
            # is this install's own, or free.
            $exe = Join-Path $Root 'canopy.exe'
            $lnk = Get-StartMenuShortcut
            $lnkTarget = Get-ShortcutTarget $lnk
            if ($null -ne $lnkTarget -and $lnkTarget -ne $exe) {
                Warn "$lnk opens $lnkTarget, not this install; left it alone (remove it, then re-run, for the Start Menu entry)"
                $receipt.Remove('shortcut')
            } else {
                $shell = New-Object -ComObject WScript.Shell
                $shortcut = $shell.CreateShortcut($lnk)
                $shortcut.TargetPath = $exe
                $shortcut.WorkingDirectory = $env:USERPROFILE
                $shortcut.IconLocation = "$exe,0"
                $shortcut.Description = 'Canopy, a fast Git client'
                $shortcut.Save()
                $receipt['shortcut'] = $lnk
            }

            $uninstallScript = Join-Path $Root 'uninstall.ps1'
            $keyLocation = Get-UninstallKeyLocation
            if ($null -ne $keyLocation -and $keyLocation -ne $Root) {
                Warn "the Apps & features entry for Canopy points at another folder ('$keyLocation'); left it alone (uninstall that copy first to get an entry for this one)"
                $receipt.Remove('uninstall_key')
            } else {
                if ($null -eq $keyLocation) { New-Item -Path $UninstallKey -Force | Out-Null }
                $size = [int]((Get-ChildItem -LiteralPath $Root -Recurse -Force -File | Measure-Object -Property Length -Sum).Sum / 1KB)
                $entries = @{
                    DisplayName          = 'Canopy'
                    DisplayVersion       = $ver
                    Publisher            = 'NecturaLabs'
                    InstallLocation      = $Root
                    DisplayIcon          = "$exe,0"
                    InstallDate          = (Get-Date -Format 'yyyyMMdd')
                    UninstallString      = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$uninstallScript`""
                    QuietUninstallString = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$uninstallScript`" -Yes"
                    URLInfoAbout         = 'https://github.com/NecturaLabs/app-updates/releases'
                }
                foreach ($k in $entries.Keys) { Set-ItemProperty -LiteralPath $UninstallKey -Name $k -Value $entries[$k] -Type String }
                Set-ItemProperty -LiteralPath $UninstallKey -Name EstimatedSize -Value $size -Type DWord
                Set-ItemProperty -LiteralPath $UninstallKey -Name NoModify -Value 1 -Type DWord
                Set-ItemProperty -LiteralPath $UninstallKey -Name NoRepair -Value 1 -Type DWord
                $receipt['uninstall_key'] = $UninstallKey
            }

            $pathNote = ''
            if ($NoPath) {
                if ($receipt.ContainsKey('path') -and $receipt['path'] -eq '1') { Remove-FromUserPath $Root }
                $receipt['path'] = '0'
            } else {
                $userPath = Get-UserPath
                if (-not (Test-PathHas $userPath $Root)) {
                    $sep = if ($userPath -eq '' -or $userPath.EndsWith(';')) { '' } else { ';' }
                    Set-UserPath "$userPath$sep$Root"
                    $receipt['path'] = '1'
                    $pathNote = 'Open a new terminal to use the canopy command.'
                } elseif (-not $receipt.ContainsKey('path')) {
                    $receipt['path'] = '0' # it was already there; not ours to remove
                }
                # This session too (the process environment, not a PowerShell variable).
                if (-not (Test-PathHas $env:Path $Root)) { $env:Path = "$env:Path;$Root" }
            }
            Write-Receipt $Root $receipt

            Say ''
            if (-not $oldVersion) { Say "Installed Canopy build $ver in $Root" }
            elseif ($oldVersion -eq $ver) { Say "Reinstalled Canopy build $ver in $Root" }
            else { Say "Updated Canopy $(Get-BuildLabel $oldVersion) -> build $ver in $Root" }
            if ($receipt.ContainsKey('shortcut')) { Say "Start Menu: $lnk" }
            if (-not $NoPath) { Say "Command:    canopy  (the folder is on your user PATH)" }
            Say 'Remove:     Settings -> Apps -> Installed apps -> Canopy, or uninstall.ps1 in the folder'
            if ($pathNote) { Say $pathNote }
        } finally {
            # Ctrl+C stops the script without running catch blocks; finally still runs.
            if ($phase) {
                if (-not (Undo-Swap $Root $previous $phase $staged)) {
                    Warn "the previous version could not be fully put back; its remaining files are in $previous"
                }
            }
            Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
            if ($lock) { Remove-Item -LiteralPath $lock -Force -ErrorAction SilentlyContinue }
            if (-not $succeeded) {
                foreach ($d in $createdDirs) {
                    if ((Test-Path -LiteralPath $d -PathType Container) -and -not (Get-ChildItem -LiteralPath $d -Force)) {
                        Remove-Item -LiteralPath $d -Force -ErrorAction SilentlyContinue
                    } else {
                        break
                    }
                }
            }
        }
    }

    # -------------------------------------------------------------------------------------------

    # Windows PowerShell 5.1 may not offer TLS 1.2 by default; this process-wide setting is put
    # back when the installer ends, so the caller's session keeps its own.
    $savedProtocols = [Net.ServicePointManager]::SecurityProtocol
    $failed = $false
    try {
        if ($Help) {
            Show-Usage
        } else {
            if ($ExtraArgs.Count -gt 0) { Fail "unknown option: $($ExtraArgs -join ' ') (see -Help)" }
            if ($env:OS -ne 'Windows_NT') {
                Fail 'install.ps1 is for Windows. On Linux and macOS run: curl -fsSL https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.sh | sh'
            }
            if ($Purge -and -not $Uninstall) { Fail '-Purge only goes with -Uninstall' }

            if ($env:CANOPY_INSTALL_BASE_URL) {
                # Test-only: a fake feed on this machine. Plain-HTTP loopback with nothing but a
                # port after the host (no path, no user-info such as http://127.0.0.1:1@elsewhere).
                if ($env:CANOPY_INSTALL_BASE_URL -cmatch '^http://(127\.0\.0\.1|localhost):([0-9]{1,5})/?\z') {
                    $LocalHost = $Matches[1]
                    $LocalPort = [int]$Matches[2]
                } else {
                    Fail 'CANOPY_INSTALL_BASE_URL is for tests and only accepts http://127.0.0.1:<port> or http://localhost:<port>'
                }
                $base = "http://${LocalHost}:$LocalPort"
                $FeedUrl = "$base/canopy"
                $ReleasesUrl = "$base/releases/download"
                Warn "test mode: using the feed at $base"
            }
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            }

            $mode = if ($Uninstall) { 'uninstall' } else { 'install' }
            $root = Join-Path $env:LOCALAPPDATA 'Programs\Canopy'
            if ($env:CANOPY_INSTALL_DIR) {
                # A relative folder is relative to PowerShell's current location, as the user sees it.
                $root = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($env:CANOPY_INSTALL_DIR)
                if (-not [IO.Path]::IsPathRooted($root)) { Fail "CANOPY_INSTALL_DIR must name a folder on disk: $($env:CANOPY_INSTALL_DIR)" }
            }
            if ($ScriptFile -and (Split-Path -Leaf $ScriptFile) -eq 'uninstall.ps1') {
                # The installed uninstall.ps1 always removes the folder it sits in.
                $mode = 'uninstall'
                $root = Split-Path -Parent $ScriptFile
            }
            $root = [IO.Path]::GetFullPath($root).TrimEnd('\')
            $forbidden = @($env:LOCALAPPDATA, (Join-Path $env:LOCALAPPDATA 'Programs'), $env:APPDATA, $env:USERPROFILE,
                $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:SystemRoot, [IO.Path]::GetPathRoot($root)) |
                Where-Object { $_ } | ForEach-Object { $_.TrimEnd('\') }
            if ($forbidden -contains $root) { Fail "refusing to use $root as Canopy's own folder; it must be a folder for Canopy alone" }

            if ($mode -eq 'uninstall') {
                Invoke-Uninstall $root
            } else {
                Invoke-Install $root
                Show-GitReport
            }
        }
    } catch [System.ApplicationException] {
        Write-Host "error: $($_.Exception.Message)" -ForegroundColor Red
        $failed = $true
        # Through `irm | iex`, `exit` would close the user's PowerShell window: throw instead.
        if (-not $ScriptFile) { throw 'The Canopy installer failed (see the error above).' }
    } catch {
        Write-Host "error: $($_.Exception.Message)" -ForegroundColor Red
        $failed = $true
        if (-not $ScriptFile) { throw }
    } finally {
        [Net.ServicePointManager]::SecurityProtocol = $savedProtocols
    }
    if ($ScriptFile) {
        if ($failed) { exit 1 }
        exit 0
    }
} -ExtraArgs $args -Invocation $MyInvocation
