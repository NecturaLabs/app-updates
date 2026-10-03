#!/bin/sh
# canopy-installer (this marker line identifies the script; keep it)
#
# Installs, upgrades or removes Canopy for the current user on Linux and macOS, without sudo:
#
#   curl -fsSL https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.sh | sh -s -- --uninstall
#
# Run with --help for the options. The script reads the update manifest in NecturaLabs/app-updates
# (canopy/latest.json, or canopy/beta.json), downloads this platform's archive over HTTPS only,
# checks its SHA-256 against the manifest and refuses anything that does not match. It never runs
# what it downloads, never asks for sudo and never installs git.
#
# Layout (Linux): everything lives in ~/.local/opt/canopy (CANOPY_INSTALL_DIR overrides it):
#   bin/canopy  share/applications/  share/icons/  share/metainfo/  legal/  LICENSE  README.md
#   VERSION  uninstall.sh  .canopy-install (the receipt: what was created outside the folder)
# Outside it, only: ~/.local/bin/canopy (a symlink; --no-path skips it), and the desktop entry and
# icons under ${XDG_DATA_HOME:-~/.local/share}/{applications,icons/hicolor}.
# Layout (macOS): ~/Applications/Canopy.app (CANOPY_INSTALL_DIR names the .app), and the
# ~/.local/bin/canopy symlink unless --no-path.
#
# Canopy's own settings and data are never touched, except by --uninstall --purge.
#
# Everything runs from main(), called on the last line, so a download cut short runs nothing.
#
# Maintainers: packaging/README.md. The source is packaging/install.sh in NecturaLabs/Canopy;
# the release workflow publishes it to NecturaLabs/app-updates/canopy/install.sh.
set -eu

APP_ID=io.necturalabs.Canopy
FEED_URL=https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy
RELEASES_URL=https://github.com/NecturaLabs/app-updates/releases/download
MIN_GLIBC=2.35

# ---------------------------------------------------------------------------------------------
# Canopy's user data, removed only by --purge. Keep this list in step with the app (and with
# packaging/install.ps1); the contract is in packaging/README.md ("Canopy's data folders").
# One "<kind> <path>" line per folder:
#   vendor  a vendor-specific name: deleted when it is a folder.
#   eframe  the folder eframe::storage_dir("canopy") gives today: deleted only when it holds
#           .canopy-data or Canopy's own files (is_eframe_canopy).
#   marker  a generic name: deleted only when it holds the .canopy-data marker file.
purge_targets() {
    case $OS in
        linux)
            printf '%s\n' \
                "eframe $(xdg_home "${XDG_DATA_HOME:-}" "$HOME/.local/share")/canopy" \
                "marker $(xdg_home "${XDG_CONFIG_HOME:-}" "$HOME/.config")/canopy" \
                "marker $(xdg_home "${XDG_STATE_HOME:-}" "$HOME/.local/state")/canopy" \
                "marker $(xdg_home "${XDG_CACHE_HOME:-}" "$HOME/.cache")/canopy"
            ;;
        darwin)
            printf '%s\n' \
                "eframe $HOME/Library/Application Support/canopy" \
                "vendor $HOME/Library/Application Support/$APP_ID" \
                "marker $HOME/Library/Logs/Canopy" \
                "vendor $HOME/Library/Caches/$APP_ID"
            ;;
    esac
}

# Whether eframe folder $1 is recognisably Canopy's: its settings key, saved tokens, or logs and
# crash reports named the way Canopy names them.
is_eframe_canopy() {
    [ -f "$1/tokens.json" ] && return 0
    if [ -f "$1/app.ron" ] && grep -q 'canopy-settings-v1' "$1/app.ron" 2>/dev/null; then return 0; fi
    for f in "$1"/logs/canopy-*.jsonl "$1"/crashes/crash-*.txt; do
        if [ -f "$f" ]; then return 0; fi
    done
    return 1
}
# ---------------------------------------------------------------------------------------------

usage() {
    cat <<'EOF'
Install Canopy for the current user (no sudo).

Usage:
  curl -fsSL https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.sh | sh -s -- [options]
  sh install.sh [options]

Options:
  --beta           Install the newest build, including beta builds (the beta channel).
  --version N      Install build N (for example 412) instead of the newest one; also the
                   way to go back to an older build.
  --no-path        Do not create the ~/.local/bin/canopy symlink.
  --uninstall      Remove Canopy: exactly the files this script created. Settings and data stay.
  --purge          With --uninstall: also delete Canopy's settings, logs and caches (asks first).
  -y, --yes        Do not ask for confirmation (for --purge).
  -h, --help       Show this help.

Environment:
  CANOPY_INSTALL_DIR   Install folder. Linux: default ~/.local/opt/canopy.
                       macOS: the app bundle, default ~/Applications/Canopy.app.
  XDG_DATA_HOME        Where the desktop entry and icons are registered (Linux).

Running the installed copy of this script, ~/.local/opt/canopy/uninstall.sh, uninstalls.
Re-running the installer upgrades in place; a failed upgrade keeps the installed build. It
never replaces a newer installed build with an older one unless --version asks for it.
EOF
}

# Messages go to fd 3, a copy of the original stderr made in main(), so that an error raised
# while a command's stderr is redirected (fetch 2>file) still reaches the user.
say() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&3; }
die() {
    printf 'error: %s\n' "$*" >&3
    exit 1
}
have() { command -v "$1" >/dev/null 2>&1; }

# $1 when it is an absolute path (the XDG base directory rules ignore relative ones), else $2.
xdg_home() {
    case $1 in
        /*) printf '%s' "$1" ;;
        *) printf '%s' "$2" ;;
    esac
}

# Paths with these characters cannot be written safely into a desktop entry's Exec= line or the
# receipt, so they are refused rather than mangled.
check_path() {
    case $1 in
        *'
'* | *'"'* | *'`'* | *'$'* | *\\* | *'%'* | *'|'*)
            die "unsupported character in path: $1 (choose a folder with CANOPY_INSTALL_DIR)"
            ;;
    esac
}

# Refuses $1 as Canopy's own folder when it is a folder other things live in.
check_root() {
    for h in "$HOME" "$HOME_P"; do
        case $1 in
            "" | / | "$h" | "$h/.local" | "$h/.local/opt" | "$h/.local/bin" | "$h/.local/share" | "$h/Applications" | /Applications | /usr | /usr/* | /opt | /bin | /etc)
                die "refusing to use $1 as Canopy's own folder; it must be a folder for Canopy alone"
                ;;
        esac
    done
}

# Records, deepest first, the folders `mkdir -p $1` is about to create, so a failed first install
# removes exactly those (and only while they are empty).
note_created_dirs() {
    d=$1
    while [ ! -e "$d" ] && [ ! -L "$d" ]; do
        CREATED_DIRS="$CREATED_DIRS$d
"
        d=$(dirname "$d")
    done
}

remove_created_dirs() {
    [ -n "$CREATED_DIRS" ] || return 0
    printf '%s' "$CREATED_DIRS" | while IFS= read -r d; do
        rmdir -- "$d" 2>/dev/null || break
    done
    CREATED_DIRS=
}

# ---------------------------------------------------------------------------------------------
# Downloads

# Picks curl, or GNU wget, before anything is downloaded; refuses clearly when neither exists.
pick_downloader() {
    if have curl; then
        DOWNLOADER=curl
    elif have wget && wget --version 2>/dev/null | grep -q 'GNU Wget'; then
        DOWNLOADER=wget
        # --no-config (wget 1.17 and later) keeps a ~/.wgetrc from changing what is fetched.
        if wget --no-config --version >/dev/null 2>&1; then WGET_NOCONFIG=--no-config; fi
    else
        die "this installer needs curl or GNU wget to download Canopy; install one with your package manager and run it again"
    fi
}

# Downloads $1 to $2. HTTPS with TLS 1.2 or newer only. curl also refuses a redirect to anything
# but HTTPS (--proto-redir) and ignores ~/.curlrc (-q). wget has no such switch: it follows the
# server's redirects as they come (GitHub's all go to HTTPS); the archive is protected either way
# by its SHA-256, which comes from the manifest. Plain HTTP only to the loopback test feed, never
# redirected.
fetch() {
    case $1 in
        https://*) plain=0 ;;
        *)
            [ -n "$LOCAL_BASE" ] || die "refusing to download over plain HTTP: $1"
            case $1 in
                "$LOCAL_BASE"/*) plain=1 ;;
                *) die "refusing to download from $1" ;;
            esac
            ;;
    esac
    [ -n "$DOWNLOADER" ] || pick_downloader
    if [ "$DOWNLOADER" = curl ]; then
        if [ "$plain" = 1 ]; then
            curl -q --fail --silent --show-error --proto '=http' --noproxy '*' --output "$2" "$1"
        else
            curl -q --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
                --tlsv1.2 --retry 3 --connect-timeout 20 --output "$2" "$1"
        fi
    else
        if [ "$plain" = 1 ]; then
            wget ${WGET_NOCONFIG:+"$WGET_NOCONFIG"} --quiet --no-proxy --max-redirect=0 \
                --output-document="$2" "$1"
        else
            wget ${WGET_NOCONFIG:+"$WGET_NOCONFIG"} --quiet --https-only --secure-protocol=TLSv1_2 \
                --tries=3 --timeout=20 --output-document="$2" "$1"
        fi
    fi
}

sha256_of() {
    if have sha256sum; then
        sha256sum -- "$1" | awk '{print $1}'
    elif have shasum; then
        shasum -a 256 -- "$1" | awk '{print $1}'
    elif have openssl; then
        openssl dgst -sha256 -r "$1" | awk '{print $1}'
    else
        die "need sha256sum, shasum or openssl to verify the download"
    fi
}

# Flattens a JSON document into "path<TAB>value" lines (object keys joined with ".", array
# items by index), enough to read the manifest without jq or python.
json_flat() {
    awk '
    function path() {
        if (d == 0) return ""
        if (kind[d] == "{") return (pre[d] == "" ? "" : pre[d] ".") key[d]
        return (pre[d] == "" ? "" : pre[d] ".") idx[d]
    }
    BEGIN { RS = "\001" }
    {
        s = $0; n = length(s); i = 1; d = 0
        while (i <= n) {
            c = substr(s, i, 1)
            if (c == "{" || c == "[") {
                p = path(); d++; kind[d] = c; pre[d] = p; idx[d] = 0; want[d] = (c == "{"); i++
            } else if (c == "}" || c == "]") {
                d--; i++
            } else if (c == ",") {
                if (kind[d] == "{") want[d] = 1; else idx[d]++
                i++
            } else if (c == ":") {
                want[d] = 0; i++
            } else if (c == "\"") {
                v = ""; j = i + 1
                while (j <= n) {
                    ch = substr(s, j, 1)
                    if (ch == "\\") {
                        nx = substr(s, j + 1, 1)
                        if (nx == "u") { v = v "?"; j += 6; continue }
                        if (nx == "n" || nx == "t" || nx == "r") nx = " "
                        v = v nx; j += 2; continue
                    }
                    if (ch == "\"") break
                    if (ch == "\t" || ch == "\n" || ch == "\r") ch = " "
                    v = v ch; j++
                }
                i = j + 1
                if (kind[d] == "{" && want[d]) key[d] = v
                else print path() "\t" v
            } else if (c ~ /[ \t\r\n]/) {
                i++
            } else {
                j = i
                while (j <= n && substr(s, j, 1) !~ /[],} \t\r\n]/) j++
                print path() "\t" substr(s, i, j - i)
                i = j
            }
        }
    }' "$1"
}

json_get() { awk -F '\t' -v k="$2" '$1 == k { print $2; exit }' "$1"; }

# Exit 0 when the dotted number $1 (such as a glibc version, 2.39.0) is greater than $2.
dotted_gt() {
    awk -v a="$1" -v b="$2" '
    function cmp(x, y,    xs, ys, nx, ny, k, r) {
        nx = split(x, xs, "."); ny = split(y, ys, ".")
        for (k = 1; k <= (nx > ny ? nx : ny); k++) {
            r = (xs[k] + 0 > ys[k] + 0) - (xs[k] + 0 < ys[k] + 0)
            if (r) return r
        }
        return 0
    }
    BEGIN { exit !(cmp(a, b) > 0) }'
}

# A build number: one to nine digits, no leading zero. The case refuses every other character,
# newlines included. Builds are ordered by this integer alone.
valid_build() {
    case $1 in
        '' | 0* | *[!0-9]*) return 1 ;;
    esac
    [ "${#1}" -le 9 ]
}

# "build 412" for a build number; anything else (such as the 0.2.0-beta.1 of an installation made
# before builds were numbered) as it is. Such a value is older than every build.
build_label() {
    if valid_build "$1"; then printf 'build %s' "$1"; else printf '%s' "$1"; fi
}

# Reads the manifest for channel $1 into $WORK/$1.flat; returns 1 when the channel has none.
read_channel() {
    if ! fetch "$FEED_URL/$1.json" "$WORK/$1.json" 2>"$WORK/$1.err"; then
        if [ "$1" = beta ]; then return 1; fi
        cat "$WORK/$1.err" >&3
        die "could not read the update manifest $FEED_URL/$1.json"
    fi
    json_flat "$WORK/$1.json" >"$WORK/$1.flat"
    v=$(json_get "$WORK/$1.flat" version)
    if ! valid_build "$v"; then
        # A manifest from before builds were numbered (a version such as 0.2.0-beta.1) is older
        # than any build: the beta channel is then treated as not published.
        if [ "$1" = beta ]; then return 1; fi
        die "the update manifest $1.json names no valid build number"
    fi
}

confirm() {
    [ "$YES" = 1 ] && return 0
    if ! (: </dev/tty) 2>/dev/null; then
        die "$1: no terminal to ask on; re-run with --yes to confirm"
    fi
    printf '%s [y/N] ' "$1" >/dev/tty
    read -r answer </dev/tty || answer=
    case $answer in y | Y | yes | YES | Yes) return 0 ;; esac
    return 1
}

# Refreshes only caches that already exist. Canopy's desktop entry declares no MIME types, so
# update-desktop-database matters only to keep an existing mimeinfo.cache current; run on a
# folder without one, it would create one, a file this script does not need. The same goes for
# a GTK icon cache.
refresh_desktop_caches() {
    [ "$OS" = linux ] || return 0
    if have update-desktop-database && [ -f "$DATA_HOME/applications/mimeinfo.cache" ]; then
        update-desktop-database -q "$DATA_HOME/applications" 2>/dev/null || true
    fi
    if have gtk-update-icon-cache && [ -f "$DATA_HOME/icons/hicolor/icon-theme.cache" ]; then
        gtk-update-icon-cache -q -t -f "$DATA_HOME/icons/hicolor" 2>/dev/null || true
    elif [ -d "$DATA_HOME/icons/hicolor" ]; then
        touch "$DATA_HOME/icons/hicolor" 2>/dev/null || true
    fi
}

# Whether $1 is a symlink pointing at $2.
links_to() { [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ]; }

# Writes file $1 to $2 through a temporary file and a rename, so that nothing is ever written
# through a symlink or other file already at $2.
put_file() {
    tmpf=$2.canopy-new.$$
    rm -f -- "$tmpf"
    if cp -- "$1" "$tmpf" && mv -f -- "$tmpf" "$2"; then return 0; fi
    rm -f -- "$tmpf"
    return 1
}

git_report() {
    say ""
    if have git; then
        say "git:      $(git --version 2>/dev/null || echo 'found')"
    else
        say "git:      NOT FOUND. Canopy needs git 2.30 or newer on PATH."
    fi
    if have git && git lfs version >/dev/null 2>&1; then
        say "git-lfs:  $(git lfs version 2>/dev/null | head -n 1)"
    else
        say "git-lfs:  not found (only needed for repositories that use Git LFS)"
    fi
    if ! have git || ! git lfs version >/dev/null 2>&1; then
        hint=
        if [ "$OS" = darwin ]; then
            hint="xcode-select --install   (git), or: brew install git git-lfs"
        elif [ -r /etc/os-release ]; then
            # shellcheck disable=SC1091
            ids=$(. /etc/os-release && printf '%s %s' "${ID:-}" "${ID_LIKE:-}")
            case " $ids " in
                *" debian "* | *" ubuntu "*) hint="sudo apt install git git-lfs" ;;
                *" fedora "* | *" rhel "* | *" centos "*) hint="sudo dnf install git git-lfs" ;;
                *" arch "*) hint="sudo pacman -S git git-lfs" ;;
                *" opensuse"* | *" suse "*) hint="sudo zypper install git git-lfs" ;;
                *" alpine "*) hint="sudo apk add git git-lfs" ;;
            esac
        fi
        say "          Install with your package manager${hint:+: $hint}"
        say "          (this installer never installs git for you)."
    fi
}

# Takes the install lock, folder $1, shared by install and uninstall.
take_lock() {
    mkdir "$1" 2>/dev/null || die "another Canopy install or uninstall is running (remove $1 if it is not)"
    LOCK=$1
}

# ---------------------------------------------------------------------------------------------
# Uninstall

# What the installer puts in the Linux install folder; uninstall removes these and nothing else.
INSTALLED_ENTRIES="bin share legal LICENSE README.md VERSION uninstall.sh .canopy-install .canopy-install.new"

# True when a receipt's icon entry "<registered copy>|<original>" names exactly the two icons the
# installer registers: a copy under .../icons/hicolor/ and its original inside this install.
# A receipt is a file the installer wrote, but uninstall must not trust it with any other path.
icon_entry_ok() {
    case $1 in
        */icons/hicolor/256x256/apps/$APP_ID.png | */icons/hicolor/scalable/apps/$APP_ID.svg) ;;
        *) return 1 ;;
    esac
    [ "$2" = "$ROOT/share/icons/hicolor/${1##*/icons/hicolor/}" ]
}

uninstall_linux() {
    if [ ! -e "$ROOT" ] && [ ! -L "$ROOT" ]; then
        say "Canopy is not installed in $ROOT; nothing to remove."
        return 0
    fi
    [ -d "$ROOT" ] || die "$ROOT is not a folder; not touching it"
    ROOT=$(cd "$ROOT" && pwd -P)
    check_path "$ROOT"
    check_root "$ROOT"
    receipt=$ROOT/.canopy-install
    [ -f "$receipt" ] || die "$ROOT has no .canopy-install receipt, so this script did not create it; not touching it"
    if [ ! -O "$ROOT" ] || [ ! -O "$receipt" ]; then
        die "$ROOT or its receipt belongs to another user; not touching it"
    fi
    take_lock "$ROOT/.lock"
    recorded=$(sed -n 's/^root=//p' "$receipt" | head -n 1)
    if [ -n "$recorded" ] && [ "$recorded" != "$ROOT" ]; then
        warn "Canopy was installed as $recorded; the command, desktop entry and icons that point there are left alone"
    fi
    say "Removing Canopy from $ROOT"
    while IFS= read -r line; do
        case $line in
            link=*)
                f=${line#link=}
                case $f in
                    */canopy) if links_to "$f" "$ROOT/bin/canopy"; then rm -f -- "$f" && say "  removed $f"; fi ;;
                esac
                ;;
            desktop=*)
                f=${line#desktop=}
                case $f in
                    */applications/$APP_ID.desktop)
                        if [ -f "$f" ] && [ ! -L "$f" ] && grep -qxF "X-Canopy-Install-Dir=$ROOT" "$f"; then
                            rm -f -- "$f" && say "  removed $f"
                        fi
                        ;;
                esac
                ;;
            icon=*)
                # icon=<registered copy>|<original inside the install folder>
                pair=${line#icon=}
                f=${pair%%|*}
                src=${pair#*|}
                if icon_entry_ok "$f" "$src" && [ -f "$f" ] && [ ! -L "$f" ] && cmp -s -- "$f" "$src"; then
                    rm -f -- "$f" && say "  removed $f"
                fi
                ;;
        esac
    done <"$receipt"
    for name in $INSTALLED_ENTRIES; do
        if [ -e "$ROOT/$name" ] || [ -L "$ROOT/$name" ]; then rm -rf -- "${ROOT:?}/$name"; fi
    done
    # Leftovers of an interrupted install.
    for e in "$ROOT"/.staging.* "$ROOT"/.previous.*; do
        if [ -e "$e" ] || [ -L "$e" ]; then rm -rf -- "$e"; fi
    done
    rmdir -- "$LOCK" 2>/dev/null || true
    LOCK=
    if rmdir -- "$ROOT" 2>/dev/null; then
        say "  removed $ROOT"
    else
        warn "$ROOT holds files the installer did not put there, so it was kept with them:"
        for e in "$ROOT"/* "$ROOT"/.[!.]* "$ROOT"/..?*; do
            if [ -e "$e" ] || [ -L "$e" ]; then printf '  %s\n' "$e" >&3; fi
        done
    fi
    refresh_desktop_caches
}

uninstall_darwin() {
    parent=$(dirname "$ROOT")
    if [ -d "$parent" ]; then ROOT=$(cd "$parent" && pwd -P)/${ROOT##*/}; fi
    APP_BIN=$ROOT/Contents/MacOS/canopy
    if [ -L "$ROOT" ]; then
        die "$ROOT is a symlink, not an app this script installed; not touching it"
    elif [ -e "$ROOT" ]; then
        id=$(bundle_id "$ROOT")
        [ "$id" = "$APP_ID" ] || die "$ROOT is not Canopy (bundle id '${id:-none}'); not touching it"
        take_lock "$(dirname "$ROOT")/.Canopy-install.lock"
        rm -rf -- "$ROOT"
        say "Removed $ROOT"
    else
        say "Canopy is not installed at $ROOT."
    fi
    if links_to "$LINK_PATH" "$APP_BIN"; then rm -f -- "$LINK_PATH" && say "Removed $LINK_PATH"; fi
}

bundle_id() {
    plist=$1/Contents/Info.plist
    [ -f "$plist" ] || return 0
    awk '/<key>CFBundleIdentifier<\/key>/ { getline; gsub(/.*<string>|<\/string>.*/, ""); print; exit }' "$plist"
}

# What --purge does with target $2 of kind $1: prints "delete", "keep" (it exists but is not
# recognisably Canopy's), or nothing when it does not exist. A symlink is never followed.
purge_verdict() {
    if [ -L "$2" ]; then
        echo keep
    elif [ ! -e "$2" ]; then
        return 0
    elif [ ! -d "$2" ]; then
        echo keep
    elif [ -f "$2/.canopy-data" ] || [ "$1" = vendor ]; then
        echo delete
    elif [ "$1" = eframe ] && is_eframe_canopy "$2"; then
        echo delete
    else
        echo keep
    fi
}

# Asks, before anything is removed, whether to delete the user data --purge would delete.
# Sets PURGE_OK=1 when there is something to delete and the user agreed.
confirm_purge() {
    PURGE_OK=0
    PURGE_LIST=$(purge_targets | while IFS= read -r line; do
        v=$(purge_verdict "${line%% *}" "${line#* }")
        if [ -n "$v" ]; then printf '%s %s\n' "$v" "${line#* }"; fi
    done)
    keep=$(printf '%s\n' "$PURGE_LIST" | sed -n 's/^keep /  /p')
    del=$(printf '%s\n' "$PURGE_LIST" | sed -n 's/^delete /  /p')
    if [ -n "$keep" ]; then
        say "--purge leaves these: each has a generic name and no .canopy-data marker file, or is a"
        say "symlink, so it may belong to another program. Check them, and remove them by hand if they are Canopy's:"
        say "$keep"
    fi
    if [ -z "$del" ]; then
        say "No Canopy settings or data found to purge."
        return 0
    fi
    say "--purge deletes Canopy's settings, logs and caches:"
    say "$del"
    if confirm "Delete them?"; then
        PURGE_OK=1
    else
        say "Keeping them."
    fi
}

purge() {
    if [ "$PURGE_OK" = 1 ]; then
        printf '%s\n' "$PURGE_LIST" | while IFS= read -r line; do
            case $line in
                "delete "*)
                    d=${line#delete }
                    # Checked again: only what was listed and still qualifies goes.
                    kind=$(purge_targets | while IFS= read -r t; do
                        if [ "${t#* }" = "$d" ]; then printf '%s' "${t%% *}"; fi
                    done)
                    if [ "$(purge_verdict "$kind" "$d")" = delete ]; then rm -rf -- "$d" && say "  removed $d"; fi
                    ;;
            esac
        done
    fi
    say ""
    say "Tokens saved in Settings -> Accounts live in tokens.json in Canopy's data folder, so a"
    say "folder removed above took them with it; Canopy does not use the system keychain yet."
}

# ---------------------------------------------------------------------------------------------
# Install

# Runs on every exit, including Ctrl+C: puts back a swap in progress, then removes the staging
# folder, the lock, and the folders a failed first install created.
cleanup() {
    trap '' INT TERM HUP
    if [ -n "$SWAP_PHASE" ]; then
        swap_rollback || warn "the previous version could not be fully put back; its remaining files are in $SWAP_OLD"
    fi
    if [ -n "$MAC_PHASE" ]; then
        if ! mac_rollback; then
            warn "the previous version could not be put back; it is at $WORK/previous.app"
            WORK=
        fi
    fi
    if [ -n "$WORK" ]; then rm -rf -- "$WORK"; fi
    if [ -n "$LOCK" ]; then rmdir -- "$LOCK" 2>/dev/null || true; fi
    remove_created_dirs
    return 0
}

# Finds the release: sets VERSION, ASSET, ASSET_URL and ASSET_SHA.
resolve_release() {
    ext=tar.gz
    if [ -n "$PIN" ]; then
        valid_build "$PIN" || die "--version $PIN is not a build number like 412"
        VERSION=$PIN
    fi
    say "Reading the update manifest"
    read_channel latest
    VERSION_LATEST=$(json_get "$WORK/latest.flat" version)
    use=latest
    if [ "$CHANNEL" = beta ] || [ -n "$PIN" ]; then
        if read_channel beta; then
            v=$(json_get "$WORK/beta.flat" version)
            if [ -n "$PIN" ]; then
                [ "$v" = "$PIN" ] && use=beta
            elif [ "$v" -gt "$VERSION_LATEST" ]; then
                use=beta
            fi
        fi
    fi
    mv=$(json_get "$WORK/$use.flat" version)
    if [ -z "$PIN" ] || [ "$PIN" = "$mv" ]; then
        VERSION=$mv
        # Never a silent downgrade: an older version only when --version asks for it.
        if [ -z "$PIN" ] && valid_build "$OLD_VERSION" && [ "$OLD_VERSION" -gt "$VERSION" ]; then
            chan="stable channel"
            [ "$CHANNEL" = beta ] && chan="beta channel"
            die "Canopy build $OLD_VERSION is installed, which is newer than build $VERSION, the newest on the $chan; nothing was changed.
  To keep getting beta builds, run the installer with --beta.
  To install build $VERSION anyway, run it with --version $VERSION."
        fi
        ASSET_URL=$(json_get "$WORK/$use.flat" "platforms.$KEY.url")
        ASSET_SHA=$(json_get "$WORK/$use.flat" "platforms.$KEY.sha256")
        if [ -z "$ASSET_URL" ]; then
            keys=$(awk -F '\t' '$1 ~ /^platforms\.[^.]*\.url$/ { sub(/^platforms\./, "", $1); sub(/\.url$/, "", $1); printf "%s ", $1 }' "$WORK/$use.flat")
            die "Canopy build $VERSION has no archive for $PRETTY ($KEY) yet. Archives in this build: ${keys:-none}"
        fi
        ASSET=${ASSET_URL##*/}
    else
        # An older or other version: its release's SHA256SUMS gives the checksum.
        ASSET=canopy-build-$VERSION-$TARGET.$ext
        say "Reading the checksums of Canopy build $VERSION"
        fetch "$RELEASES_URL/canopy-build-$VERSION/SHA256SUMS" "$WORK/SHA256SUMS" 2>"$WORK/sums.err" ||
            die "Canopy build $VERSION is not published (no $RELEASES_URL/canopy-build-$VERSION/SHA256SUMS)"
        ASSET_SHA=$(awk -v f="$ASSET" '{ n = $2; sub(/^\*/, "", n) } n == f { print $1; exit }' "$WORK/SHA256SUMS")
        [ -n "$ASSET_SHA" ] || die "Canopy build $VERSION has no archive for $PRETTY ($KEY)"
        ASSET_URL=$RELEASES_URL/canopy-build-$VERSION/$ASSET
    fi
    # Only ever download Canopy's own archive from Canopy's own release in the feed repository.
    [ "$ASSET_URL" = "$RELEASES_URL/canopy-build-$VERSION/$ASSET" ] ||
        die "the manifest points outside Canopy's releases: $ASSET_URL"
    [ "$ASSET" = "canopy-build-$VERSION-$TARGET.$ext" ] ||
        die "unexpected archive name in the manifest: $ASSET"
    printf '%s\n' "$ASSET_SHA" | grep -Eq '^[0-9a-f]{64}$' ||
        die "the manifest has no valid sha256 for $ASSET"
}

download_and_verify() {
    say "Downloading $ASSET_URL"
    fetch "$ASSET_URL" "$WORK/$ASSET" || die "download failed: $ASSET_URL"
    got=$(sha256_of "$WORK/$ASSET")
    if [ "$got" != "$ASSET_SHA" ]; then
        die "checksum mismatch for $ASSET
  expected $ASSET_SHA
  got      $got
Nothing was installed. Try again later; if it persists, report it."
    fi
    say "Checksum verified (sha256 $got)"
    mkdir -p "$WORK/x"
    tar -xzf "$WORK/$ASSET" -C "$WORK/x" || die "could not unpack $ASSET"
    SRC=$WORK/x/canopy-build-$VERSION-$TARGET
    [ -d "$SRC" ] || die "$ASSET does not contain canopy-build-$VERSION-$TARGET/"
}

# Builds the new install folder's content in $1 from the unpacked archive.
stage_linux() {
    new=$1
    [ -f "$SRC/canopy" ] || die "$ASSET has no canopy binary"
    mkdir -p "$new/bin" "$new/share/applications" "$new/share/metainfo" \
        "$new/share/icons/hicolor/256x256/apps" "$new/share/icons/hicolor/scalable/apps"
    cp "$SRC/canopy" "$new/bin/canopy"
    chmod 755 "$new/bin/canopy"
    for f in README.md LICENSE; do
        if [ -f "$SRC/$f" ]; then cp "$SRC/$f" "$new/$f"; fi
    done
    if [ -d "$SRC/legal" ]; then cp -R "$SRC/legal" "$new/legal"; fi
    if [ -f "$SRC/$APP_ID.desktop" ]; then
        entry=$new/share/applications/$APP_ID.desktop
        # Exec= and the install marker belong to the [Desktop Entry] group only; other groups
        # (desktop actions) keep their own Exec= lines.
        awk -v ex="Exec=\"$ROOT/bin/canopy\" %F" -v marker="X-Canopy-Install-Dir=$ROOT" '
            function close_main() { if (main && !done) { print marker; done = 1 } }
            /^[ \t]*\[/ { close_main(); main = ($0 == "[Desktop Entry]") }
            main && /^Exec[ \t]*=/ { print ex; next }
            main && /^X-Canopy-Install-Dir[ \t]*=/ { next }
            { print }
            END { close_main() }' "$SRC/$APP_ID.desktop" >"$entry"
        if ! grep -qxF "X-Canopy-Install-Dir=$ROOT" "$entry"; then
            warn "$ASSET has a desktop entry without a [Desktop Entry] group; not registering it"
            rm -f -- "$entry"
        fi
    fi
    if [ -f "$SRC/$APP_ID.metainfo.xml" ]; then cp "$SRC/$APP_ID.metainfo.xml" "$new/share/metainfo/"; fi
    if [ -f "$SRC/$APP_ID.png" ]; then cp "$SRC/$APP_ID.png" "$new/share/icons/hicolor/256x256/apps/"; fi
    if [ -f "$SRC/$APP_ID.svg" ]; then cp "$SRC/$APP_ID.svg" "$new/share/icons/hicolor/scalable/apps/"; fi
    printf '%s\n' "$VERSION" >"$new/VERSION"
    install_self "$new/uninstall.sh"
}

# Downloads $1 to $2 and keeps it only if it is this installer.
fetch_self() {
    fetch "$1" "$2" 2>/dev/null && sed -n 2p "$2" | grep -q '^# canopy-installer' &&
        sh -n "$2" 2>/dev/null
}

# Copies this script (the uninstaller is the installer run as uninstall.sh) to $1.
install_self() {
    if [ -f "$0" ] && sed -n 2p "$0" 2>/dev/null | grep -q '^# canopy-installer'; then
        cp "$0" "$1"
    elif fetch_self "$FEED_URL/install.sh" "$1" || fetch_self "${ASSET_URL%/*}/install.sh" "$1"; then
        : # Piped into sh: the published copy of this script, or (before a stable release has
        # published one) the copy attached to the release just installed, fetched again.
    else
        warn "could not save uninstall.sh; uninstall with the one-line installer and --uninstall"
        rm -f -- "$1"
        return 0
    fi
    chmod 755 "$1"
}

# Moves the staged content ($1) into $ROOT, replacing the old version, in two phases: "aside"
# moves the old Canopy entries into .previous.*, "in" moves the staged ones into place. On a failure,
# or an interrupt (cleanup), swap_rollback undoes exactly the phase reached.
swap_in() {
    new=$1
    SWAP_NAMES=$WORK/staged-names
    for e in "$new"/*; do
        if [ -e "$e" ] || [ -L "$e" ]; then printf '%s\n' "${e##*/}"; fi
    done >"$SWAP_NAMES"
    SWAP_OLD=$(mktemp -d "$ROOT/.previous.XXXXXX") || return 1
    SWAP_PHASE=aside
    # Only the installer's own entries move aside, never a file the user keeps in the folder. The
    # receipt (a hidden name) stays until integrate_linux replaces it: it says which icons are ours.
    for name in $INSTALLED_ENTRIES; do
        case $name in .*) continue ;; esac
        e=$ROOT/$name
        [ -e "$e" ] || [ -L "$e" ] || continue
        mv -- "$e" "$SWAP_OLD/" || {
            swap_abort
            return 1
        }
    done
    SWAP_PHASE=in
    for e in "$new"/*; do
        [ -e "$e" ] || [ -L "$e" ] || continue
        mv -- "$e" "$ROOT/" || {
            swap_abort
            return 1
        }
    done
    SWAP_PHASE=
    rm -rf -- "$SWAP_OLD"
    SWAP_OLD=
}

swap_abort() {
    kept=$SWAP_OLD
    swap_rollback || die "could not install the new version, nor put all of the previous one back.
  Its remaining files are in $kept: move them back into $ROOT, or run the installer again."
}

# Puts the previous version back. In phase "in" it first removes the entries that came from the
# staging folder (by then every old entry is aside, so nothing else has those names). It never
# deletes an old entry, and never moves one over an existing name. Returns 1 when something
# could not be put back; the rest stays in $SWAP_OLD.
swap_rollback() {
    phase=$SWAP_PHASE
    SWAP_PHASE=
    ok=1
    if [ "$phase" = in ]; then
        while IFS= read -r name; do
            [ -n "$name" ] || continue
            if [ -e "$ROOT/$name" ] || [ -L "$ROOT/$name" ]; then rm -rf -- "${ROOT:?}/$name" || ok=0; fi
        done <"$SWAP_NAMES"
    fi
    for e in "$SWAP_OLD"/*; do
        [ -e "$e" ] || [ -L "$e" ] || continue
        if [ -e "$ROOT/${e##*/}" ] || [ -L "$ROOT/${e##*/}" ]; then
            ok=0
            continue
        fi
        mv -- "$e" "$ROOT/" || ok=0
    done
    [ "$ok" = 1 ] || return 1
    rmdir -- "$SWAP_OLD" 2>/dev/null || true
    SWAP_OLD=
    return 0
}

# Registers the desktop entry, icons and command outside the install folder; writes the receipt.
# Each is written only where nothing else owns the name: a desktop entry must carry this
# install's X-Canopy-Install-Dir marker, an icon must be in this install's receipt, and a
# symlink at either is never written through.
integrate_linux() {
    receipt=$ROOT/.canopy-install
    tmp_receipt=$ROOT/.canopy-install.new
    {
        printf '# Written by the Canopy installer: what it created outside %s.\n' "$ROOT"
        printf 'root=%s\n' "$ROOT"
        printf 'version=%s\n' "$VERSION"
    } >"$tmp_receipt"

    apps=$DATA_HOME/applications
    entry=$apps/$APP_ID.desktop
    if [ -f "$ROOT/share/applications/$APP_ID.desktop" ]; then
        if [ -L "$entry" ]; then
            warn "$entry is a symlink, not this installer's desktop entry; left it alone (remove it, then re-run, to get Canopy in the app menu)"
        elif { [ -e "$entry" ] && [ ! -f "$entry" ]; } ||
            { [ -f "$entry" ] && ! grep -qxF "X-Canopy-Install-Dir=$ROOT" "$entry"; }; then
            warn "$entry is not this installer's desktop entry; left it alone (remove it, then re-run, to get Canopy in the app menu)"
        elif mkdir -p "$apps" && put_file "$ROOT/share/applications/$APP_ID.desktop" "$entry"; then
            printf 'desktop=%s\n' "$entry" >>"$tmp_receipt"
        else
            warn "could not write $entry"
        fi
    fi
    for rel in "256x256/apps/$APP_ID.png" "scalable/apps/$APP_ID.svg"; do
        src=$ROOT/share/icons/hicolor/$rel
        [ -f "$src" ] || continue
        dst=$DATA_HOME/icons/hicolor/$rel
        if [ -L "$dst" ]; then
            warn "$dst is a symlink, not this installer's icon; left it alone"
            continue
        fi
        if [ -e "$dst" ] && ! grep -qxF "icon=$dst|$src" "$receipt" 2>/dev/null; then
            # Someone else's copy; an identical one shows the same icon and needs no warning.
            if [ ! -f "$dst" ] || ! cmp -s -- "$dst" "$src"; then
                warn "$dst was not installed by this installer; left it alone"
            fi
            continue
        fi
        if mkdir -p "$(dirname "$dst")" && put_file "$src" "$dst"; then
            printf 'icon=%s|%s\n' "$dst" "$src" >>"$tmp_receipt"
        else
            warn "could not write $dst"
        fi
    done
    link_command "$ROOT/bin/canopy" "$tmp_receipt"
    mv -f -- "$tmp_receipt" "$receipt"
    refresh_desktop_caches
}

# Creates or removes the ~/.local/bin/canopy symlink to $1; records it in receipt $2 if given.
link_command() {
    if [ "$LINK" = 1 ]; then
        if { [ -e "$LINK_PATH" ] || [ -L "$LINK_PATH" ]; } && ! links_to "$LINK_PATH" "$1"; then
            warn "$LINK_PATH already exists and is not this installer's link; left it alone (remove it, then re-run, to get the 'canopy' command)"
            return 0
        fi
        if ! { mkdir -p "$BIN_DIR" && ln -sf -- "$1" "$LINK_PATH"; }; then
            warn "could not create $LINK_PATH; the 'canopy' command was not set up"
            return 0
        fi
        if [ -n "${2:-}" ]; then printf 'link=%s\n' "$LINK_PATH" >>"$2"; fi
        case ":${PATH:-}:" in
            *":$BIN_DIR:"*) ;;
            *) PATH_HINT=1 ;;
        esac
    elif links_to "$LINK_PATH" "$1"; then
        rm -f -- "$LINK_PATH"
        say "Removed $LINK_PATH (--no-path)"
    fi
}

install_linux() {
    if [ -L "$ROOT" ] && [ ! -e "$ROOT" ]; then die "$ROOT is a broken symlink"; fi
    if [ -e "$ROOT" ] && [ ! -d "$ROOT" ]; then die "$ROOT exists and is not a folder"; fi
    if [ ! -d "$ROOT" ]; then
        note_created_dirs "$ROOT"
        mkdir -p "$ROOT"
    fi
    # The real path, so the symlink, desktop entry and receipt name the folder exactly as the
    # installed uninstall.sh sees it (it resolves its own folder with pwd -P).
    ROOT=$(cd "$ROOT" && pwd -P)
    check_path "$ROOT"
    check_root "$ROOT"
    if [ ! -f "$ROOT/.canopy-install" ] && [ -n "$(ls -A "$ROOT")" ]; then
        die "$ROOT is not empty and was not created by this installer; choose another CANOPY_INSTALL_DIR"
    fi
    take_lock "$ROOT/.lock"
    WORK=$(mktemp -d "$ROOT/.staging.XXXXXX")
    if [ -f "$ROOT/.canopy-install" ] && [ -f "$ROOT/VERSION" ]; then OLD_VERSION=$(head -n 1 "$ROOT/VERSION"); fi

    resolve_release
    download_and_verify
    mkdir "$WORK/new"
    stage_linux "$WORK/new"
    swap_in "$WORK/new" || die "could not move the new version into $ROOT; the previous one was kept"
    # The folder is Canopy's from here on: keep it, and claim it with a receipt at once.
    CREATED_DIRS=
    if [ ! -f "$ROOT/.canopy-install" ]; then
        printf '# Written by the Canopy installer.\nroot=%s\n' "$ROOT" >"$ROOT/.canopy-install"
    fi
    integrate_linux

    say ""
    if [ -z "$OLD_VERSION" ]; then
        say "Installed Canopy build $VERSION in $ROOT"
    elif [ "$OLD_VERSION" = "$VERSION" ]; then
        say "Reinstalled Canopy build $VERSION in $ROOT"
    else
        say "Updated Canopy $(build_label "$OLD_VERSION") -> build $VERSION in $ROOT"
    fi
    if [ "$LINK" = 1 ] && links_to "$LINK_PATH" "$ROOT/bin/canopy"; then
        say "Command:  $LINK_PATH -> $ROOT/bin/canopy"
    fi
    if grep -q '^desktop=' "$ROOT/.canopy-install"; then
        say "Launcher: $DATA_HOME/applications/$APP_ID.desktop"
    fi
    say "Remove:   $ROOT/uninstall.sh"
}

# Puts the previous app bundle back after an interrupted or failed swap (see install_darwin).
mac_rollback() {
    phase=$MAC_PHASE
    MAC_PHASE=
    prev=$WORK/previous.app
    [ -e "$prev" ] || return 0
    if [ "$phase" = in ] && { [ -e "$ROOT" ] || [ -L "$ROOT" ]; }; then
        mv -- "$ROOT" "$WORK/failed.app" || return 1
    fi
    if [ -e "$ROOT" ] || [ -L "$ROOT" ]; then return 1; fi
    mv -- "$prev" "$ROOT"
}

install_darwin() {
    parent=$(dirname "$ROOT")
    if [ ! -d "$parent" ]; then
        note_created_dirs "$parent"
        mkdir -p "$parent"
    fi
    ROOT=$(cd "$parent" && pwd -P)/${ROOT##*/}
    check_path "$ROOT"
    APP_BIN=$ROOT/Contents/MacOS/canopy
    if [ -L "$ROOT" ]; then die "$ROOT is a symlink; not replacing it"; fi
    if [ -e "$ROOT" ]; then
        id=$(bundle_id "$ROOT")
        [ "$id" = "$APP_ID" ] || die "$ROOT exists and is not Canopy (bundle id '${id:-none}'); not replacing it"
    fi
    take_lock "$(dirname "$ROOT")/.Canopy-install.lock"
    WORK=$(mktemp -d "$(dirname "$ROOT")/.Canopy-install.XXXXXX")
    if [ -f "$ROOT/Contents/Info.plist" ]; then
        OLD_VERSION=$(awk '/<key>CFBundleShortVersionString<\/key>/ { getline; gsub(/.*<string>|<\/string>.*/, ""); print; exit }' "$ROOT/Contents/Info.plist")
    fi

    resolve_release
    download_and_verify
    [ -x "$SRC/Canopy.app/Contents/MacOS/canopy" ] || die "$ASSET has no Canopy.app"
    [ "$(bundle_id "$SRC/Canopy.app")" = "$APP_ID" ] || die "$ASSET holds an app with the wrong bundle id"
    mv -- "$SRC/Canopy.app" "$WORK/Canopy.app"
    if [ -e "$ROOT" ]; then
        # Two renames; MAC_PHASE lets cleanup put the old app back if either is interrupted.
        MAC_PHASE=aside
        if ! mv -- "$ROOT" "$WORK/previous.app"; then
            MAC_PHASE=
            die "could not move the old $ROOT aside; nothing changed"
        fi
        MAC_PHASE=in
        if ! mv -- "$WORK/Canopy.app" "$ROOT"; then
            mac_rollback || {
                WORK=
                die "could not install the new version, nor put the previous one back; it is at $prev"
            }
            die "could not install the new version; the previous one was kept"
        fi
        MAC_PHASE=
    else
        mv -- "$WORK/Canopy.app" "$ROOT" || die "could not create $ROOT"
    fi
    CREATED_DIRS=
    link_command "$APP_BIN" ""

    say ""
    if [ -z "$OLD_VERSION" ]; then
        say "Installed Canopy build $VERSION as $ROOT"
    elif [ "$OLD_VERSION" = "$VERSION" ]; then
        say "Reinstalled Canopy build $VERSION as $ROOT"
    else
        say "Updated Canopy $(build_label "$OLD_VERSION") -> build $VERSION at $ROOT"
    fi
    if [ "$LINK" = 1 ] && links_to "$LINK_PATH" "$APP_BIN"; then
        say "Command:  $LINK_PATH -> $APP_BIN"
    fi
    say "Open it from Launchpad or Spotlight. Remove: re-run this installer with --uninstall."
}

# ---------------------------------------------------------------------------------------------

main() {
    # fd 3: the user's stderr, for say/warn/die (see die).
    exec 3>&2
    # A CDPATH would make `cd` print, and $(cd ... && pwd -P) return two lines.
    unset CDPATH

    MODE=install
    CHANNEL=latest
    PIN=
    LINK=1
    PURGE=0
    YES=0
    SELF_DIR=
    LOCAL_BASE=
    DOWNLOADER=
    WGET_NOCONFIG=
    WORK=
    LOCK=
    SWAP_PHASE=
    SWAP_OLD=
    SWAP_NAMES=
    MAC_PHASE=
    CREATED_DIRS=
    OLD_VERSION=
    PATH_HINT=0
    PURGE_OK=0
    PURGE_LIST=

    case ${0##*/} in
        uninstall.sh)
            MODE=uninstall
            SELF_DIR=$(cd "$(dirname "$0")" && pwd -P)
            ;;
    esac

    while [ $# -gt 0 ]; do
        case $1 in
            --beta) CHANNEL=beta ;;
            --version)
                [ $# -ge 2 ] || die "--version needs a value, for example --version 412"
                PIN=$2
                shift
                ;;
            --version=*) PIN=${1#--version=} ;;
            --no-path) LINK=0 ;;
            --uninstall) MODE=uninstall ;;
            --purge) PURGE=1 ;;
            -y | --yes) YES=1 ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                printf 'error: unknown option: %s (see --help)\n' "$1" >&3
                exit 2
                ;;
        esac
        shift
    done
    if [ "$PURGE" = 1 ] && [ "$MODE" != uninstall ]; then
        die "--purge only goes with --uninstall"
    fi
    PIN=${PIN#v}

    # Test-only: tools and CI point the script at a fake feed on this machine. Only a plain-HTTP
    # loopback URL with nothing but a port after the host is accepted, so this can never send a
    # real install anywhere else; fetch() then allows plain HTTP to exactly that base.
    if [ -n "${CANOPY_INSTALL_BASE_URL:-}" ]; then
        url=$CANOPY_INSTALL_BASE_URL
        only="CANOPY_INSTALL_BASE_URL is for tests and only accepts http://127.0.0.1:<port> or http://localhost:<port>"
        case $url in
            http://127.0.0.1:*) host=127.0.0.1 ;;
            http://localhost:*) host=localhost ;;
            *) die "$only" ;;
        esac
        # Everything after "host:", less one trailing slash, must be digits: no path, no
        # user-info trick such as http://127.0.0.1:1@elsewhere.example.
        port=${url#"http://$host:"}
        port=${port%/}
        case $port in
            '' | *[!0-9]*) die "$only" ;;
        esac
        [ ${#port} -le 5 ] || die "$only"
        LOCAL_BASE=http://$host:$port
        FEED_URL=$LOCAL_BASE/canopy
        RELEASES_URL=$LOCAL_BASE/releases/download
        warn "test mode: using the feed at $LOCAL_BASE"
    fi

    # Platform
    [ -n "${HOME:-}" ] || die "HOME is not set"
    case $HOME in
        /*) ;;
        *) die "HOME must be an absolute path (it is $HOME)" ;;
    esac
    case $(uname -s) in
        Linux) OS=linux ;;
        Darwin) OS=darwin ;;
        MINGW* | MSYS* | CYGWIN* | Windows_NT)
            die "on Windows, run this in PowerShell instead:
  irm https://raw.githubusercontent.com/NecturaLabs/app-updates/main/canopy/install.ps1 | iex"
            ;;
        *) die "Canopy has no build for $(uname -s); it runs on Linux, macOS and Windows" ;;
    esac
    case $(uname -m) in
        x86_64 | amd64) ARCH=x86_64 ;;
        aarch64 | arm64) ARCH=aarch64 ;;
        *) die "Canopy has no build for $(uname -m) processors yet (only x86_64 and arm64)" ;;
    esac
    # An x86_64 shell under Rosetta on an Apple silicon Mac should still get the native build.
    if [ "$OS" = darwin ] && [ "$ARCH" = x86_64 ] && [ "$(sysctl -n hw.optional.arm64 2>/dev/null || true)" = 1 ]; then
        ARCH=aarch64
    fi
    KEY=$OS-$ARCH
    case $KEY in
        linux-x86_64) TARGET=x86_64-unknown-linux-gnu ;;
        linux-aarch64) TARGET=aarch64-unknown-linux-gnu ;;
        darwin-x86_64) TARGET=x86_64-apple-darwin ;;
        darwin-aarch64) TARGET=aarch64-apple-darwin ;;
    esac
    case $OS in
        linux) PRETTY="Linux $ARCH" ;;
        darwin) PRETTY="macOS $ARCH" ;;
    esac

    # Paths
    DATA_HOME=$(xdg_home "${XDG_DATA_HOME:-}" "$HOME/.local/share")
    BIN_DIR=$HOME/.local/bin
    LINK_PATH=$BIN_DIR/canopy
    HOME_P=$HOME
    if [ -d "$HOME" ]; then HOME_P=$(cd "$HOME" && pwd -P); fi
    if [ "$OS" = linux ]; then
        # The installed uninstall.sh always removes the folder it sits in.
        ROOT=${SELF_DIR:-${CANOPY_INSTALL_DIR:-$HOME/.local/opt/canopy}}
    else
        ROOT=${CANOPY_INSTALL_DIR:-$HOME/Applications/Canopy.app}
    fi
    case $ROOT in
        /*) ;;
        *) ROOT=$(pwd -P)/$ROOT ;;
    esac
    while :; do
        case $ROOT in
            ?*/) ROOT=${ROOT%/} ;;
            *) break ;;
        esac
    done
    if [ "$OS" = darwin ]; then
        case $ROOT in
            *.app) ;;
            *) die "on macOS, CANOPY_INSTALL_DIR names the app bundle and must end in .app" ;;
        esac
    fi
    for p in "$ROOT" "$HOME" "$DATA_HOME"; do check_path "$p"; done
    check_root "$ROOT"
    APP_BIN=$ROOT/bin/canopy

    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP

    if [ "$MODE" = uninstall ]; then
        if [ "$PURGE" = 1 ]; then confirm_purge; fi
        case $OS in
            linux) uninstall_linux ;;
            darwin) uninstall_darwin ;;
        esac
        if [ "$PURGE" = 1 ]; then
            purge
        else
            say "Settings and data were kept (--uninstall --purge removes them)."
        fi
        exit 0
    fi

    say "Installing Canopy for $PRETTY"
    for tool in tar gzip awk mktemp uname; do
        have "$tool" || die "this installer needs '$tool'"
    done
    pick_downloader
    if [ "$OS" = linux ]; then
        # The Linux build needs glibc 2.35 or newer (Ubuntu 22.04, Debian 12, Fedora 36 and later).
        glibc=$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}' || true)
        if [ -n "$glibc" ]; then
            if dotted_gt "$MIN_GLIBC.0" "$glibc.0"; then
                die "Canopy needs glibc $MIN_GLIBC or newer; this system has $glibc"
            fi
        elif ldd --version 2>&1 | grep -qi musl; then
            die "Canopy's Linux build needs glibc; musl systems (such as Alpine) are not supported yet"
        else
            warn "could not tell the C library version; Canopy needs glibc $MIN_GLIBC or newer"
        fi
    fi

    case $OS in
        linux) install_linux ;;
        darwin) install_darwin ;;
    esac

    if [ "$PATH_HINT" = 1 ]; then
        say ""
        say "Note: $BIN_DIR is not on your PATH, so 'canopy' will not run by name yet. Add this to"
        say "your shell profile (~/.profile, ~/.bashrc or ~/.zshrc) and open a new terminal:"
        say "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    git_report
}

main "$@"
