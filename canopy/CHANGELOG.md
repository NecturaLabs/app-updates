# Canopy release notes

The notes of every Canopy build, newest first. Only the current builds keep a release; this file
keeps the notes of the ones that were removed.

<!-- release: canopy-build-1996 2026-11-21T01:11:48Z -->
## Canopy build 1996 (21 November 2026)

### Added

- Only trust update manifests signed by the release key.
- Credit outside contributors in the release notes.
- Say what to do when a force push finds the remote changed.
- Add Stage file to an unstaged file's diff header.
- Colour the code by language, as the diff does.

### Fixed

- Run only the installer and archive the signed manifest names.
- Find a deleted worktree however its folder is spelled.
- Run a planned search at the instant it is due.
- Keep Git for Windows' shell from expanding wildcards in a path.
- Stop the ignore preview hanging on many long paths.
- A force push no longer overwrites commits you never saw.
- Let visitors pause the palette tour.
- Never let git act on input that was cut short.
- Filter GitLab drafts with draft on GitLab 19 and newer.
- Pin the force push to the remote's own tracking branch.
- Keep focus when the tour button hides.
- Send GitLab's draft filter as a boolean.
- Move focus to the first section link when the button hides.
- Say how to track a branch before a force push.
- Say the force push tip is from your last fetch.
- Skip GitLab's version read without a sign-in.
- Show badge links and titles without hidden characters.
- Expose the cause of a missing git through source().
- Capture a chord by pressing its modifiers and key.
- Say Canopy's own code is MIT or Apache-2.0 in the notices.
- Read GitLab's major version without copying the answer.
- Fade the tour button in with the palette.
- Keep the privacy links on one row and the footer links on one line.
- Keep the icon out of the palette's section labels.
- Show blank characters as spaces and clean every host name.
- Drop ignored shortcuts and say how many an import ignored.
- Stop a stale force push with a Fetch button and plainer copy.
- Warn when an import ignored shortcuts.
- Say a stopped force push may mean the branch was deleted.
- Refuse a key pressed while Super is held in a capture.
- Name the palette tour button for what it does next.
- Say plainly what a force push replaces.
- Call a captured key combination a shortcut.
- Keep the status bar whole with a long branch name.
- Keep the commit message beside long ref pills in History.
- Keep a path's last folder in view.
- Never cut a commit's ids in narrow commit details.
- Show File history's commit messages whole.
- Offer git-flow setup from Start and Finish.
- Centre one-line settings titles on their controls.
- Put every settings heading the same distance below its rows.
- Give every notification row the same height.
- Give Clean up stale the same compact rows as Clean up merged.
- Keep a request's "updated" time whole when its line wraps.
- Line up sidebar folders and branches at each level.
- Show that the command palette's list goes on.
- Keep the diff header on one row when it fits.
- Drop "without consent" from Export settings.
- Give callouts the full width of their form.
- Say why a branch name is refused.
- Explain Repository insights' counts plainly and date them like the app.
- Say a reason every merged branch shares only once.
- Explain Forget missing worktrees without git's file names.
- Mark the crash question's facts in the accent.
- Give a settings row one help mark.
- Leave Merge… the only filled button on an open request.
- Label every theme card Dark or Light.
- Move the toolbar tools that do not fit into a More menu.
- Keep each toolbar tool's focus its own as tools move into More.
- Tie the diff header's Stage and Unstage buttons to their file.
- Stop the diff header redrawing when its controls wrap alone.
- Drop a blame's colours when its lines change.
- Name no count when no missing worktree is found.
- Say submodule loss only for a worktree that has submodules.
- Say forgetting loses unpushed submodule commits and a worktree's own refs.
- Say a forget confirmation is gone once its tab closed.
- Open the force-delete question on Cancel.
- Say what force deleting a branch compares and how to get it back.
- Say when HEAD's reflog keeps a force-deleted branch's tip.
- Keep the conflict notice off the resolver's Save buttons.
- Offer a forced delete from the branch's state, not git's words.
- Show the rest of git's error, a few lines at most.
- Shorter identity hint, and say the tooltip is capped.
- Count commits a missing worktree's own refs hold.
- Flatten reference badges and addresses with parentheses.
- Say why a key was refused and keep the buttons in place.
- Keep colour fades under reduced motion, stop only movement.
- Say what git decides when it sets only one autostash key.
- Show branch names without characters that reorder text.
- Say what removing a worktree loses in Forget's words.
- Open repositories with ref names too long for libgit2.
- Count commits a worktree's own refs hold on removal.
- Refuse a removal when a worktree's own refs moved.

### Changed

- Bump rfd from 0.17.2 to 0.18.0 in the cargo group.
- Regenerate the third-party notices for rfd 0.18.

<!-- release: canopy-build-1683 2026-11-18T09:51:56Z -->
## Canopy build 1683 (18 November 2026)

### Fixed

- The trust-safety-off notice and the untrusted-repository banner can be dismissed.

<!-- release: canopy-build-1661 2026-11-18T08:11:04Z -->
## Canopy build 1661 (18 November 2026)

### Added

- Remove merged branches the remote deleted after a fetch that prunes.

### Fixed

- A shallower branch tree without repeated icons and words.
- No scroll bar beside an empty commit message body.
- Show the whole folder in the Trust and New worktree dialogs.
- One card for a notice that repeats while it shows.
- Say how long a repository's tab name can be.
- A glyph of its own for a possibly squash-merged branch.
- An enter-arrow, not a tick, for Check out.
- End the interrupted-update notices with a full stop.
- A Fetch heading over the fetch rows, out of the git configuration list.

<!-- release: canopy-build-1648 2026-11-18T04:43:35Z -->
## Canopy build 1648 (18 November 2026)

### Added

- The first public build of Canopy, now open source under MIT OR Apache-2.0: a fast, Linux-first
  Git client for Linux, macOS and Windows.
- History with a commit graph, search, blame and file history; staging by file, hunk or line;
  commits, amends and stashes; branches, tags, remotes, worktrees and submodules; merge, rebase,
  cherry-pick and revert, with three-way conflict resolution.
- GitHub and GitLab (self-hosted included) pull and merge requests through your `gh` or `glab`
  sign-in, with checks and reviews; Canopy stores no token.
- Keyboard first: a command palette, a shortcut cheatsheet, vim motions and single-key actions.
- Themes with high-contrast variants, interface zoom, reduced motion, and settings that show your
  git configuration beside Canopy's recommendations.
- In-app updates, opt-in crash reports, and no telemetry.

<!-- release: canopy-build-1279 2026-10-13T00:43:42Z -->
## Canopy build 1279 (13 October 2026)

### Added

- Ask before amending a commit that is already pushed.
- State the outcome first in the repository hosting block.
- Fetch the request list one page at a time.
- Load more requests on demand.
- Read the signed-in gh or glab token.
- Use the signed-in gh or glab for pull and merge requests.
- Search history for changed text with the pickaxe.
- Search the history for changed text.
- Search requests on the host.
- Search and filter requests that are not loaded.
- Quieter text fields and separate commit subject and body.
- Pin the commit box and quiet the Changes page.
- Load the next page when the list scrolls to its end.

### Fixed

- Select the row a context menu acts on when right-clicking.
- Read again when the kernel interrupts a wait for a response.
- Write the hosting status as plural sentences.
- End the wait only on the page that was asked for.
- Keep repository diff programs and the searched text out of history search.
- Keep the token out of the Debug output of a resolved credential.
- Read the CLI sign-in per account and bound its output.
- Say which source an account's token comes from.
- Keep the date whole in change search results.
- Scroll a link Tab reaches into view in the reader.
- Stop asking for a token when the host is unreachable.
- Cut redundant markers and copy from the settings pages.
- Show the recommended value of every setting.
- Hide unprefixed tokens, passwords and emails.
- Find an address's start on a character boundary.
- Name settings by label and explain every row.
- Label conflict sides by branch and use Accept wording.
- Size selects and fields to their content.
- Let zoom and quit work while a dialog is open.
- Read again when a crash report's reply is interrupted.
- Keep the dialog open when git refuses a worktree.
- Write dates in the calendar format chosen in Settings.
- Ignore common words when searching settings.
- Stop warning when a git setting is simply unset.
- Keep every subtitle on one line and drop config paths.
- Show a row's notes as a mark beside its title.
- Offer a repository only the choices git leaves to it.
- List the recommended choice first in every select.
- Write the consent dates the way the documents do.
- Say why Pull requests is unavailable.
- Say plainly what the welcome dialog promises.

<!-- release: canopy-build-1200 2026-10-11T00:54:14Z -->
## Canopy build 1200 (11 October 2026)

### Added

- A stronger resting well and joined field pairs.
- One message box for the commit summary and description.
- Edit Git configuration from Settings.
- Read a file's history across renames.
- Read who last changed each line of a file.
- Show who last changed each line with Blame.
- Show a file's history across renames.
- Add a linked worktree on a new or an existing branch.
- Add a Worktree button and dialog to the top bar (#138).

### Fixed

- Drop Recommended prose from Git setting help.
- Keep conflict choices when switching between conflicted files.
- Keep Blame from running repository programs or going stale.
- Keep file history from downloading and bind it to its tab.
- Keep focus in the composer after Enter and after a commit.
- Make Git settings and file history clearer.
- Say what Use recommended writes and tidy review findings.

<!-- release: canopy-build-1165 2026-10-10T18:00:00Z -->
## Canopy build 1165 (10 October 2026)

### Added

- Refresh the open request list on a timer.

### Fixed

- Keep the timed refresh within the host's rate limits.
- Respect refresh backoff after Git syncs.

<!-- release: canopy-build-1140 2026-10-10T03:28:26Z -->
## Canopy build 1140 (10 October 2026)

### Added

- Indent the rows under their section headers.
- Open only Branches in a new tab and drop the Remotes header's menu.
- Tidy a request's action row and drop the credential line.
- Say what commit signing will do and warn when it would fail.

### Fixed

- Colour the lines in a request's summary line.
- Group repeated notices and keep the bar off the rows.
- Open the configuration file git reports, not a relative path.
- Match gpg.format exactly as git does.
- Judge a signing key as git does and keep only its label.
- Say no token when none was sent, not that it was refused.
- Flag a token as refused only from reads.

<!-- release: canopy-build-1116 2026-10-10T02:37:34Z -->
## Canopy build 1116 (10 October 2026)

### Added

- Use recommended Git choices and stop following the git config.

### Fixed

- Show the same git settings notice once.
- Start a button's spinner at the click and fade it in.
- Label the commit id and its parents in commit details.
- Show what git does on greyed choices and reset every Git choice.
- Drop the repository from a notice several share.
- Left-align the Commit and Parent labels.

<!-- release: canopy-build-1104 2026-10-10T00:32:10Z -->
## Canopy build 1104 (10 October 2026)

### Added

- Move notification preferences to their own section (#34).
- Add ignore rules and ignored-file management.
- List submodules in snapshots, validate adds, log pointer moves.
- Manage submodules from the sidebar, palette and diff.
- Update submodules after pull and checkout and in clones.
- Give form fields and selects a roomier default height.
- Explain how to install git when it is missing.
- Add Stage selected beside Stage all.
- Say what a file mode or link type change means.
- Say which repositories Stage all left out.
- Select several unstaged files and stage them together.
- Name the programs a repository needs and the system lacks.
- Draw light-theme text fields as plates.
- Keep the center across restarts and report git settings.
- Change the keys in Settings.
- Retry failed diffs, mark files, convert old clones.
- Publish any branch and stage untracked folders on purpose.
- Export commits as patch files and apply patch files.
- Read the configured commit template.
- Export a commit as a patch and apply patch files.
- Start an empty message with the commit template.
- Verify a commit's signature with git.
- Show whether a commit's signature verifies.
- Safely preview and remove stale worktrees and branches.
- Add stale worktree and branch cleanup dialog.
- Calculate local repository and branch insights.
- Show repository activity and branch metrics.
- Show a Verified badge for a signature git trusts.
- Link an author to their profile or a user search.
- Open an author card from the name and link parents.
- Parents first, and the commit id is a link that copies it.
- Name the host on the author-card link for self-hosted forges.
- Show the lines of a file/symbolic link type change.
- A type change's hunks name the whole file as the way to stage it.
- Say when a request's checks and reviews are not loaded.
- Check a commit message's summary and description widths.
- Hint at a summary or description line that is too long.
- Export several commits as patches at once.

### Fixed

- Reject reserved HEAD when naming refs.
- Show GitLab host credential errors under Host.
- Remove host-blind environment token API.
- Keep newly arriving routine cards visible.
- Surface failed remote pruning configuration reads.
- Redact credential-bearing URLs and share token prefixes.
- Sanitize hosting error text before client-token redaction.
- Terminate option parsing for branch and push arguments.
- Reject credentials in malformed one-slash helper URLs.
- Identify the default theme on its card (#31).
- Disable repository fsmonitor commands (#28).
- Map operation status by type instead of label (#23).
- Handle typed toolbar operations in success messages (#23).
- Apply topic filters to cards already visible (#35).
- Retain libgit2 cause when resolving merge base (#74).
- Outline selected theme tick against preview (#32).
- Reject unisolated direct captures before logging (#72).
- Isolate home and Git state on both display paths (#72).
- Avoid stale pointer-keyed indentation cache (#26).
- Remove leftover appearance spacing on notifications page (#34).
- Preserve profile transport errors without leaking lookup URLs.
- Retain picture download failure causes safely.
- Skip disabled rows during keyboard list navigation.
- Treat escaped file placeholders as literal text.
- Sanitize invalid embedded desktop-entry field codes.
- Include linked worktree config in download trust gate.
- Open notification preferences from the status bar.
- Remove orphaned legacy SVG only for owned installs (#38).
- Clean legacy SVG omitted from older receipts (#38).
- Update download-gate callback and pending rustfmt (#37).
- Restore keyboard focus after the command palette closes (#24).
- Focus search on opening preferences.
- Show keyboard focus on command search.
- Focus search after modal acquires focus.
- Reuse the active tab when switching worktrees.
- Refresh selected details with a manual list reload.
- Reject obsolete details for reselected requests (#29).
- Restore executable project check scripts (#73).
- Omit private application commands on native captures (#72).
- Inspect runtime colours after test-only items (#64).
- Treat checkout, merge and rebase targets as refs (#12).
- Reject unsafe embedded desktop file fields (#13).
- Preserve custom icons without an ownership receipt (#38).
- Preserve details when a quiet list refresh fails (#29).
- Keep default theme captions clear of names (#31).
- Redact normalized tokens and JSON error values.
- Preserve authored drafts when switching worktrees.
- Align local-only status with toolbar and sidebar.
- Keep select menus within their dialog or panel.
- Focus the first empty field when the dialog opens.
- Preview paths a literal negation makes visible.
- Make submodule recursion follow git's configuration and Canopy's switch.
- Show select lists above modals and scroll to the highlight.
- Ease buttons in on press and keep a quick press visible.
- Do not report a missing accessibility bus as a crash.
- Say what the path field wants and show a rule's pattern as code.
- Drop a submodule from the list once its removal is staged.
- Do not say an added submodule has no commits between.
- Keep the preview of a negation true to git's matching.
- Keep quick button presses visible after release.
- Keep missing accessibility services out of crash reports.
- Update recorded commits after resolving a pull.
- Match literal negation previews to Git.
- Refresh pointer diffs and virtualize sidebar.
- Reveal typed matches after opening with the mouse.
- Disclose automatic submodule downloads.
- Keep auto-fetch from running a repository's own programs.
- Remember a failed download until Retry and stop a hung one.
- Keep a clone whose submodules cannot be downloaded.
- Tab through the title bar tools left to right.
- Make the section list and theme cards one tab stop each.
- Give keyboard focus back when Settings closes.
- Ignore a stale path when a pattern is saved at the root.
- Say sign-in was cancelled when a credential prompt is cancelled.
- Drop an unedited merge message when the merge ends.
- Remove staging files after failed cache writes (#9).
- Include worktree Git folders and retire stale refusals (#37).
- Protect and identify symbolic-link targets (#44).
- Fast-forward single-commit feature and bugfix finishes (#58).
- Disclose saved tokens in Windows purge warning (#39).
- List remote branches when a remote has a setting libgit2 cannot parse.
- Keep the Git LFS probe from running a repository's alias.
- Neutralise what an untrusted automatic fetch could run.
- Save no URL passwords in the notification center.
- Name the conflicting files when applying a patch stops.
- Make a timed-out download retryable.
- A plain click on the open file drops the marked files.
- Keep the staged files in view in a small window.
- Name the number of fields in the signature format.
- Handle shared objects and safe branch comparisons.
- Title the dialog by what it removes.
- List the clean-stale overlay in the help.
- Keep repository insights read-only and bounded.
- Read only a regular commit template of bounded size.
- Never replace a patch file that is already in the folder.
- Apply only from a full path.
- A signed commit git cannot check is not shown as unsigned.
- Ask for the signature again when a folder becomes trusted.
- Say one commit, not 1 commits.
- Read commit.template only in trusted folders.
- Keep a repository's sequence.editor from running.
- Remove an orphaned scalable icon that is byte for byte one Canopy shipped.
- Count both sides of a type change in a commit's file list.
- A file replaced by a submodule entry diffs instead of failing.
- Hide the request path and email a server repeats in a profile error.
- Read the file that was checked for a type change, guard a unix-only test, anchor the numeric-literal opt-out.
- Load templates after trusting an open repository.
- Hide private profile data with invisible characters.
- Count large file-type changes without preview limits.
- Show both text sides of file and submodule changes.
- Distinguish oversized previews from binary files.
- Export a patch series parents first whatever the commit dates.
- Keep a hostile include and a deinitialised submodule out of automatic Git work.
- Let an untouched commit template yield to amend, merge and squash messages.
- Fit the branch table to the dialog without scrolling sideways.
- Say why a failed Git command failed, not how it began.
- Keep cover letters out of exported patches and honour core.commentChar in templates.
- Show squash hints without running merge programs.
- Retain unread counts and remote rejection reasons.
- Restore dialog triggers after app-level Escape.
- Distinguish invalid and unavailable verification.
- Preserve messages and latest worktree choices.
- Preserve existing files during concurrent exports.
- Bound attribute reads and ignore symlink hints.

### Changed

- Avoid assigning a root repository name every frame.
- Borrow roving row state instead of cloning every list (#26).
- Scan the worktrees once per validation pass.

<!-- release: canopy-build-828 2026-10-07T05:49:12Z -->
## Canopy build 828 (7 October 2026)

### Fixed

- Agree the likely-conflict text with the commit count.
- Name the branch in the force delete question.
- Stop git's progress being glued to its result.
- Keep the bare keys working after a button keeps focus.
- Bring the active tab back when focus leaves the strip.
- Tell a success in words, not git's chatter.
- Do not mark a menu's first item after a right click.
- Focus a row when it is clicked.
- Keep the tools in place as the counts come and go.
- Show which button Enter will press.
- Turn the bell badge danger for an unread error.
- Say why a button is unavailable at every tooltip level.
- Keep the longest relative date uncut in Dense.
- Keep a settings file from enabling tag pruning or pushes.
- Say when a remote already has an untracked branch.
- Refuse an invalid initial branch name before creating anything.
- Name the branch and its destination before a force push.
- Ask again when the remote moved while you decided.
- List Shift+F10 in the cheatsheet and keyboard settings.
- Make a disabled icon button read as disabled.
- Meet WCAG 2.2 AA in text fields and links.
- Keep the page still when a theme is chosen.
- Stop a settings file fetching more often or turning on betas.
- Force push only the branch the question named.
- Letters typed into an open list no longer fire shortcuts.
- Refuse branch names git expands before creating the folder.
- Do not ask about a moved upstream with nothing new.
- Name rebase or merge when the remote changed meanwhile.
- Keep room for the "99+" badge so the switcher stays put.
- Say where Push really sends an untracked branch.
- Esc closes an open link menu before the reader.
- Say a merging pull brought everything in.
- Size the Date column for the widest absolute date.
- Bring in the commit that was checked, not the newest.
- Tab meets a reset button before its control.
- Refuse a first branch name git refuses as it is typed.
- Place reset buttons beside their control, centred.
- Show focus on the palette and cheatsheet search.
- Fall back to main when a saved first branch is invalid.
- Never reuse a work directory name within a process.

<!-- release: canopy-build-763 2026-10-07T03:55:58Z -->
## Canopy build 763 (7 October 2026)

### Added

- Keep tab names whole and scroll long tab strips.
- Mark the item you clicked and branches in other worktrees.
- Add a notification center and choose which pop up.
- Show only helpful tooltips by default, with a setting.
- Redesign branch and tag pills.
- List worktrees in their own section.
- Give every ref pill one calm design.
- Drop the commit information block from commit details.
- Mark the open worktree with the checked-out check.
- Make primary and danger buttons tonal.
- Give a repository without a remote a proper card.
- Drop the details disclosure from cards.
- Ask for decisions with named buttons.
- Check before pulling and use recommended git defaults.
- Respect your git configuration and pull with one fetch.
- Colour each ref pill in its graph lane.
- Recommend rebasing diverged branches and remember everywhere.
- Give select boxes the look of the controls around them.
- Cleaner text fields and links.
- Fill ref pills with their lane colour and a white label.
- Try white labels on the tonal ref pills.

### Fixed

- Keep the pull request list current after a sync.
- Keep a submenu open on the way to it.
- Close the center when its links open something.
- Keep upstreams and focus the window in the user simulation.
- Keep links for navigation and make actions buttons.
- Offer Copy only on failures in the center.
- Tighten cards in the Dense density.
- Force push only the current branch and prune per remote.
- Show git's error when a pull cannot fetch.
- Say which operations the autostash switch still decides.
- Let a repository's threads end before Canopy exits.
- Force push only to the branch's own destination.
- Close tabs without waiting and wait for threads at exit.
- Stop crashing when a dialog closes with a screen reader on.
- Drop the Esc cancels and Esc closes footer hints.
- Clearer prompts and tighter wording across the app.
- Answer a pull or delete question in the repository that asked.
- Give usersim fixtures without an origin the bare clone.

<!-- release: canopy-build-706 2026-10-06T11:26:31Z -->
## Canopy build 706 (6 October 2026)

### Added

- Add a custom theme and make High contrast a switch.
- Add High contrast to the theme menu and command palette.

### Fixed

- Keep the chosen side's executable bit on Windows.
- Keep your settings when a saved choice no longer exists.

<!-- release: canopy-build-690 2026-10-06T07:51:22Z -->
## Canopy build 690 (6 October 2026)

### Added

- Rebuild the themes and add Style, Density and Motion.
- Lay out the window chrome by style and density.
- Add kit toggles, segmented control, tabs and slider.
- Add kit text fields and select.
- Add rows, chips, avatars, surfaces and the graph to the kit.
- Add kit menus, dialogs, popovers, progress and toast cards.
- Make Translucent surfaces blur behind the command palette.
- Fill the row, switch and slider gaps the views worked around.
- Give each of the eight themes its own designed palette.
- Float Deeper's action bar and split History into two cards.
- Add DocTabs, the title bar's repository tabs.
- Give banners and callouts disabled actions with reasons.
- Set Style, Density, Translucent surfaces and Motion.
- Offer Publish or Add remote when there is no forge.
- Search every setting from the top of Settings.
- Show how Fetch, Pull and Push ended on the tool itself.
- Read the terms in a full-size reader, finish open dialog.
- Add the split handle for resizable panes.
- Give each theme a world of its own.
- Redesign text fields and selects as one set.
- Let selects size themselves to their longest option.
- Show the kit tooltip on every control, by the pointer on rows.
- Give each repository its own pull, fetch and commit choices.
- Say why a clone or update failed inside its dialog.
- Give the start screen a clearer, calmer layout.
- Give the file lists and the diff a card each in Deeper.
- Report a failed clone in the form that started it.
- Show the editor, terminal and file manager Canopy uses.
- Show every request's checks and review in the list.
- Let buttons show an operation running, then how it ended.
- Pick the editor, terminal and file manager from those installed.
- Explain in Privacy why authors show initials.
- Rename a repository's tab, pick its icon, change remote URLs.
- Add a reading width for document dialogs.
- Review consent, reset settings, and import or export them.
- Slide list rows when the repository changes them.
- Explain beside the author why pictures are missing.
- Say why authors show initials and open the fix.
- Pick a pull strategy per repository and from the toolbar.
- Give each theme its own corners, light, type and art.
- Give text fields and selects the theme's focus ring.
- Let a repository tab show its own icon.
- Resize History's details and the Changes lists from the keyboard.
- Build the Terms and Privacy reader on the kit dialog.

### Fixed

- Keep unsalted kit inputs apart and finish field slots.
- Blur behind menus, popovers, dialogs and toasts.
- Keep the changes list inside the content pane.
- Centre settings fields with their row's other controls.
- Keep the title search right-aligned and list the merge target.
- Stop a shortcut with a symbol key from crashing its tooltip.
- Say why the install lock could not be taken.
- Stop an escaped quote hiding code from the unsafe scan.
- Blur the backdrop before the layer's shadow is painted.
- Open commit information the same way in every density.
- Show the operation banner the same way in every view.
- Delete blur objects only on the thread that owns them.
- Keep disabled controls readable.
- Fade clipped field text and show the guide only when used.
- Show commit information only when its first line fits.
- Lift a light theme's backdrop as a whole, not to one grey.
- Keep solid scroll bars thin and quiet.
- Fade illustration glows smoothly instead of in rings.
- Use the kit tooltip instead of stock hover text.
- Make skeleton rows visible and let them wait for the delay.
- End overlay scroll bodies clear of the card edge.
- Pause timers on hover and slide cards into place.
- Keep dialogs clear of the tab strip and status bar.
- Stop the gallery's pages at its end and number them.
- Let Tab reach a dialog's buttons in reading order.
- Keep stacked avatar initials clear of the next avatar.
- Set the conflict card's main choices apart.
- Give the commits-per-page stepper room.
- Smooth the edge of the background glows.
- Let translucent surfaces show more of what lies behind.
- Let select lists fade out when they close.
- Show chip and pill tooltips on the kit tooltip.
- Paint the background glows without rings.
- Show task lists in descriptions as checkboxes.
- Keep Settings clear of the tab strip and status bar.
- Keep Unified live for new and deleted files.
- Show which tool is running and keep the requests count.
- Finish the pull and merge requests view.
- Fade overflowing tabs into the ground they stand on.
- Show author pictures after a token is added or a push.
- Add remotes from the Remotes header, not a full-width button.
- Give Deeper's action bar room inside its card.
- Keep the details pane in place while a commit loads.
- Show disabled controls in clear, neutral disabled colours.
- Send no repository check once pictures are turned off.
- Fit the action bar in narrow windows without a scroll bar.
- Keep a server's refusal message to short plain text.
- Always pass the chosen strategy to git.
- Follow the git configuration's pull strategy by default.
- Stop glass menus and dialogs from blurring their own shadow.
- Give split buttons a proper menu with aligned options.
- Cap how many unpushed commits a tab remembers.
- Pad the detached HEAD pill for the chosen density.
- Show initials for GitLab authors without a picture.
- Wait again before showing a spinner for each new load.
- Pause the list's checks after any GitHub rate limit.
- Show commit information beside the changed files.
- Reach a section header's action with the keyboard.
- Send nothing more once pull requests are turned off.
- Resume list checks within an hour of any rate limit.
- Stop a huge Retry-After from crashing pull requests.
- Reach a section header's action with Shift+Tab too.
- Open a request without waiting for the list's checks.
- Show and log a server's error text as plain text.
- Drop every invisible character from a server's refusal.
- Offer one Add remote when a repository has no remote.
- Show every server error as plain, short text.
- Show the update server's errors as plain, short text.
- Keep remote branches when pruning is off.
- Show how Fetch, Pull and Push ended with a check or a mark.
- Stop author lookups when pull requests are turned off.
- Keep a rate limit's reset time within a day.
- Open a request without waiting for the list's checks.
- Keep a server's refusal text out of the log.
- Use the kit's number field for zoom and commits per page.
- Keep the shadow under small tooltips soft.
- Show a refused download address as plain, short text.
- Queue no checks when their thread could not start.
- Say why a clone failed in the clone form.
- Explain an empty branch list under its select.
- Ask confirmations as questions with named answers.
- Paint disabled chips and cards in the disabled colours.
- Colour the checks summary by how the checks went.
- Show the commit tooltip in the app's own style.
- Keep a text field at the right of a right-to-left row.
- Soften the aurora, the forge glow and the neon floor.
- Let the theme backdrop stand alone behind the start screen.
- Set every title in the theme's heading face.
- Show each repository's chosen icon on its tab.
- Ask confirmations as questions that name what is lost.
- Name a remote's own prune setting in the prune note.
- Never splice a file name into another argument.
- Keep programs, token hosts and local paths out of files.
- Read desktop entries only up to a size limit.
- Recognise credentials in every URL spelling git accepts.
- Refuse credentials and option-like input for remotes.
- Say why a typed URL is refused and hide clone credentials.
- Never show or log a token a server echoes back.
- Read a git setting written without a value as true.
- Keep a picture host's limit from hiding an author's picture.
- Keep checks that came with the last request of the quota.
- Apply, pop or drop the stash you chose, not its old place.
- Make Skip this version in the status bar last.
- Accept exactly the branch and tag names git accepts.
- Let Escape go back from reading the terms.
- Remove credentials from URLs with extra slashes.
- Stop the scroll glide when motion is reduced.
- Offer one Delete for a file both sides deleted.
- Let Ctrl+F reach Settings search with no repository open.
- Pop the stash the toolbar names, even if the list changed.
- Free the Open form when the opener thread is gone.
- Show code exactly as typed, without ligatures.
- Hide the secret again in every new prompt.
- Keep a closed tab's commit message until it opens again.
- Read an old skipped build as its number.
- Open Accounts from a toast the way Settings opens.
- Draw Chinese, Japanese and Korean text.
- Name the window for screen readers.
- Keep disabled banner actions readable.
- Let screen readers read the diff.
- Name code blocks and fit nested snippets in their boxes.
- Underline links at rest in Paper and Contrast.
- Never paint the line-picking hint over a long hunk title.
- Make lists one Tab stop with the arrows inside.
- Keep icon glyphs out of what screen readers say.
- Say when Commit, Continue and Save cannot run yet.
- Read each welcome quick action once.
- Make dialogs, the palette and the cheatsheet modal.
- Scroll the page to a control Tab moves onto.
- Hide a revealed secret on the next prompt.
- Fade a Settings page into its card where it continues.
- Keep the commit button's label whole in a narrow column.
- Fade out a tool the action bar cuts at its edge.
- Open context menus from the keyboard.
- Draw the commit fields' scroll bar as a thin handle.
- Show git's message on every error.
- Say a command's placeholder must be a word of its own.
- Put options inside their group for screen readers.
- Leave keyboard focus alone when dragging a split.
- Keep a sliding indicator's leading edge in front.
- Resize the request list from the keyboard like other panes.
- Open the Terms and Privacy Policy at the top.
- Speak a callout's title and text once, without its icon.
- Say when a control is unavailable and why.

### Changed

- Stop copying settings and remotes on every frame.

<!-- release: canopy-build-324 2026-10-04T17:08:37Z -->
## Canopy build 324 (4 October 2026)

### Added

- Add an Init repository shortcut.
- Offer ISO calendar dates for commit history.
- Add guarded approve and merge request shortcuts.
- Refine controls and keep compact layouts usable.

### Fixed

- Make instructional placeholders consistent.
- Spell out Comma in the settings shortcut.
- Add a pointer close control to shortcuts.
- Present local-only repository state as status text.
- Distinguish draft requests in the list.
- Give Comment a clear primary action.
- Separate reset names from their effects.
- Deepen the dark dialog backdrop.
- Calm Ember selection fills.
- Make toolbar captions easier to read.
- Align dates and change counts with tabular glyphs.
- Open commit information by default.
- Give the welcome status bar a useful state.
- Name an unborn branch in repository status.
- Name each review state in text.
- Explain every merge choice before selection.
- Explain capital-letter shortcuts.
- Make small avatar initials legible.
- Keep matching author and host avatars consistent.
- Explain repository actions on their cards.
- Tighten the illustration and center the stack.
- Distinguish remote actions from branch rows.
- Keep requests visible without a supported remote.
- Reserve scrollbar space in legal documents.
- Give identity saving a clear primary action.
- Lead updates with build status and actions.
- Make account card status and links consistent.
- Use more of the available desktop space.
- Use a solid fill for primary actions.
- Use readable sentence case for section headings.
- Balance columns without splitting groups.
- Group commands under category headings.
- Give Ember and Forest their own graph colours.
- Give source and target branches their own line.
- Show scroll continuation at table edges.
- Let the inspector grow with taller windows.
- Preserve useful space for rows in short windows.
- Fit columns to the currently visible commits.
- Hide the inspector until commits exist.
- Extend the file header across the pane.
- Distinguish saving progress from resolving a file.
- Open resolution from the unresolved file action.
- Number context lines and restore readable ink.
- Place each side choice beside its code.
- Name current and incoming versions in plain language.
- Surface context commands and reuse shortcut rows.
- Group merge controls and foreground the description.
- Foreground fingerprints and balance host trust choices.
- Explain errors and offer repository-safe recovery.
- Keep operation state and recovery visible in every view.
- Keep details and load more controls reachable.
- Separate keycaps and clarify conflict choices.
- Bound settings rows and notification heights.
- Preserve drafts and enforce submission eligibility.
- Match refreshed state and wrap merge controls.
- Keep squash messages separate from amend drafts.

<!-- release: canopy-build-253 2026-10-04T09:32:46Z -->
## Canopy build 253 (4 October 2026)

### Added

- Remove the open-source licences screen from the app.
- Follow the lists with the composer and give a clean tree a home.

### Fixed

- Fit drop-downs to their dialog and give them the app's caret.
- Show git's own error when it stops before reading its input.
- Give the checks list the same caret as other expanders.
- Show the whole rail of the diff's context-lines slider.
- Keep scrollbar handles long enough to see and grab.
- Keep settings text clear of the scrollbar and links whole.
- Size every standalone icon from one scale.
- Retry and widen the cleanup of the old scalable icon.
- Name the custom-drawn rows and buttons for screen readers.
- Register the one icon without a single-item loop.
- Drop the third-party credits from the About dialog.
- Show the git version in About instead of the status bar.
- Say what Pop does and which stash it applies.
- Mark untracked files with U instead of git's question mark.
- Show the summary length only once there is a summary.
- Give the diff options a title, a clear value and a segmented whitespace choice.
- Tidy Settings: theme cards, privacy text, keyboard list, fields.
- Show a new or deleted file as one column in side-by-side mode.
- Soften the tint of a wholly new or deleted file.
- Make Stage hunk the primary action and Discard a quiet ghost.
- Drop the language label from the diff header.
- Fade a line that runs past the pane edge.
- Label discard-all away from Stage and hide empty change lists.
- Stop marking the crash-report reassurance with a red cross.
- Make destructive confirmations a solid danger button.
- Say why Commit is disabled and draw it clearly disabled.
- Label the credential field and call a key passphrase unlocking.
- Show example values and the reason Save is disabled in the identity dialog.
- Name the current branch in the merge and rebase choices.
- Put the broader trust choice behind a warning in the trust dialog.
- Make Check for updates the one action in the About dialog.

### Changed

- List the merge dialog's branches only while its menu is open.

<!-- release: canopy-build-192 2026-10-03T21:40:30Z -->
## Canopy build 192 (3 October 2026)

### Added

- Draw the illustrations in each theme's own colours.
- Redraw the app icon around the new logo mark.
- Add a high-contrast theme and rebalance Neon and Forest.
- Polish every control, the type scale and empty states.
- Adapt the layout to small and very large windows.

### Fixed

- Grow a new illustration in even where another just was.
- Explain an empty diff side only for new or deleted files.
- Dim the unselected options of segmented controls.

<!-- release: canopy-build-173 2026-10-03T16:12:59Z -->
## Canopy build 173 (3 October 2026)

### Added

- Download only in folders you trust.

### Fixed

- Refuse to uninstall when the owner check cannot run.
- Show pictures of authors whose commit changed many files.
- Keep an author due after a picture lookup was skipped.
- Author pictures no longer starve pull requests of API calls.
- Size the file header's controls from how they laid out.
- Withdraw trust at once and ask again before each download.
- Check trust at every fetch and keep the Trust chip honest.
- Read a trusted folder's root-ness without touching the disk and clear the chip after a good diff.
- Answer the download gate for the list in force and keep trusted folders absolute.
- Tell a stale refusal from a fresh one and clear the chip when nothing is left to explain.
- Report a download core stopped as a refusal and drop the chip when the file closes.
- Keep the environment's repository variables away from git.
- Drop a refusal that outlives the diff it was for.
- Let the Downloads off chip explain only refusals.

<!-- release: canopy-build-146 2026-10-03T10:21:14Z -->
## Canopy build 146 (3 October 2026)

### Added

- Show author profile pictures cached for twelve hours.

### Fixed

- Stay responsive when the window is on another workspace.
- Keep the user's files on upgrade and trust no receipt path.
- Title the author column "Author".
- Keep progress and completion dialogs compact.
- Improve spacing and navigation across the app.

<!-- release: canopy-build-124 2026-10-02T20:46:45Z -->
## Canopy build 124 (2 October 2026)

### Added

- Show and edit the Git author identity.

### Fixed

- Report refused repositories and undo a half-done clear.

<!-- release: canopy-build-120 2026-10-02T11:24:57Z -->
## Canopy build 120 (2 October 2026)

### Added

- Update from inside Canopy. The update dialog's Update button downloads the new build over HTTPS
  from Canopy's release, checks its SHA-256 against the update feed and installs it. Where the
  one-line installer put Canopy (Linux) it replaces its own folder in place, keeps the previous
  version if anything fails, keeps the command link, launcher entry, icons and `uninstall.sh`
  consistent, and never touches settings, tokens, logs or caches. Any other installation runs the
  one-line installer pinned to the new build. A restart button follows. Nothing is downloaded until
  you press Update; the Privacy Policy describes it.
- GitHub and GitLab (self-hosted GitLab included): forge icons on remotes, "Open on" links for
  commits, branches and remotes, and a pull and merge request view with checks, reviews and the
  conversation, plus create, check out, comment, approve, merge and close, through the host's REST
  API with a token you provide (Settings → Accounts, kept per host and port; an environment
  variable or git's credential helper also works). Requests can be turned off in Settings →
  Integrations.
- Local-only repositories show a "local only" badge, and Publish adds a remote and pushes. The
  clone and add-remote dialogs build the address from `owner/repo` with an HTTPS or SSH choice.
- Seven themes (Midnight, Daylight, Aurora, Ember, Neon, Forest and Paper), interface zoom, reduced
  motion and a settings screen (Ctrl+,) for appearance, Git, integrations, accounts, updates and
  privacy. Every option applies at once.
- A keyboard map in one table: palette, a searchable cheatsheet (`?` or Ctrl+/), vim motions and
  single-key Git actions, never Super and never while typing. `docs/keybindings.md` lists it.
- Credential and SSH passphrase prompts, and host-key questions, in Canopy's own dialog instead of
  failing, whenever git or ssh needs one.
- Staging, unstaging and discarding single lines of a hunk, side-by-side diffs, syntax highlighting,
  and context-line and whitespace options for diffs, global or per repository.
- A three-way conflict resolver (ours, theirs, both, the common ancestor or an edit by hand), and
  merge modes: default, no fast-forward, fast-forward only and squash.
- Each repository tab shows its commits to push and pull.
- An update check against Canopy's own feed, a "What's new" dialog after an upgrade, and the option
  to turn the check off.
- Structured JSON-lines logs per run and local crash reports in Canopy's data folder, with Settings
  → Copy diagnostics. Opt-in, scrubbed crash reports to NecturaLabs, asked on first start together
  with the Terms of Service and Privacy Policy, which can be read in the app.
- SVG illustrations for the empty states and the welcome screen (placeholders until the final
  art).
- One-line installers for Linux and macOS (`curl -fsSL …/canopy/install.sh | sh`) and Windows
  (`irm …/canopy/install.ps1 | iex`): per-user, no sudo, a folder of Canopy's own, SHA-256
  checked downloads, in-place upgrades and a clean uninstall. macOS builds are now a
  `Canopy.app` bundle.

### Security

- Files Canopy reads or writes inside a repository (the conflict resolver) refuse paths that leave
  the working tree, name `.git`, or cross a symbolic link; a conflicted file behind a symlinked
  folder now gives an error instead of opening.
- A credential or host-key prompt can no longer be replaced or dropped by another dialog; dialogs
  queue behind it, and Escape on a host-key question answers "no".
- Crash reports also scrub credentials in every URL, GitHub and GitLab token patterns, `Bearer`
  values, and home folders only at whole-path boundaries.
- Saved hosting tokens are kept per host and port, so a GitLab instance on another port no longer
  shares a token with the default one.
- Programs Canopy opens (terminal, editor, browser) never inherit the credential prompt's secret.
- The installers' test-only feed override accepts nothing but a loopback host and a port, so a
  value such as `http://127.0.0.1:1@elsewhere.example` is refused. `install.ps1` follows
  redirects itself and refuses any that is not HTTPS; `install.sh` ignores `~/.curlrc` and
  `~/.wgetrc`.
- The installers never write through a symlink or over a desktop entry, icon, Start Menu shortcut
  or Apps & features entry that another install owns, and `--purge` deletes a generically named
  folder (`canopy`) only when it is marked as Canopy's (`.canopy-data`) or holds Canopy's own
  files.

### Fixed

- Pull uses the chosen strategy (merge, rebase or fast-forward only) whenever `git` itself has
  no `pull.rebase` setting. Canopy read the setting through libgit2, which ignores
  `GIT_CONFIG_GLOBAL`, so it could skip the strategy, and recent versions of Git refuse to
  pull diverged branches without one.
- Commit details restore a readable height after a small window is enlarged. Expand and a
  compact History/Commit details switch give the author, changed files and diff useful space.
  A shorter initial pane leaves less empty space under short diffs.
- History search now appears only when invoked with Ctrl+F or `/`; those shortcuts, Esc and the
  close button hide it and restore the full graph. The redundant commit count and status-bar
  repository path are removed.
- Commit detail Expand and Back sit at the right end of the filename row instead of adding another
  header row. Ref and request pills use clearer color fills and legible text; opened context submenu
  items match hovered menu items rather than flashing purple.
- Interface zoom no longer moves the Settings slider during a drag; percentage entry now parses
  correctly; increasing zoom no longer increases the native window minimum size.
- Clone destination validation runs off the UI thread and keeps the entered values on failure.
- Native folder selection keeps the app event loop running while browsing instead of causing
  operating-system unresponsive warnings.
- Compact settings, legal text, shortcuts, palette, diff controls and history labels stay within
  their viewport; long paths no longer overlap status counts.
- Staging, unstaging and discarding use each path literally: a file named `*` or `[ab].txt` no
  longer touches other files (discarding an untracked `[ab].txt` used to delete an untracked
  `b.txt` too).
- Deleting a branch from the sidebar runs `git branch -d`: a branch with unmerged commits is no
  longer deleted silently, and Canopy asks before forcing it.
- Opening a large repository no longer freezes the window: the repository is opened and its file
  watcher set up off the UI thread.
- Commits, checkouts and fetches in a linked worktree or submodule now refresh Canopy: their git
  folder (and the shared common folder) is watched too. The watcher no longer follows symbolic
  links.
- Installers: a failed or interrupted (Ctrl+C) upgrade puts the previous version back without
  ever deleting part of it; uninstall removes only the installer's own files and keeps the folder
  when it holds anything else; re-running no longer silently replaces a newer version (such as a
  beta) with an older one; a failed first install leaves no empty folders behind and does not
  claim an existing empty folder; a symlinked home folder no longer breaks uninstall; errors
  during downloads, including a missing `curl` and `wget`, are always shown; a script cut short
  in download runs nothing; and through `irm | iex` the Windows installer leaves the PowerShell
  session as it found it.
- Partial clones (`git clone --filter=blob:none` or `--filter=tree:0`) no longer fail with
  "object not found" when you open an old commit or its diff: Canopy downloads the missing
  objects through your `git` (the status bar says from where) and shows git's own message, with a
  Retry button, when that fails. The commit's file list appears at once, and its line counts
  follow once downloaded (commits over 200 files keep the list without counts). Selecting several
  commits quickly downloads only for the last one. After a soft reset in a treeless clone the
  history still loads, and the Changes view says why it cannot list changes yet instead of
  showing every file as added. A remote whose name looks like a git option is refused, never
  run. Partial clones made by Git before 2.24 get a message with the commands that convert them.
- Secondary and faint text, links, status colours and graph lanes are readable on every surface
  they are drawn on, selected rows and diff lines included, in all seven themes (WCAG AA; body
  text AAA). Selected values in Settings use the same calmer selection fill as lists. Branch and
  tag pills, avatar initials and change and count badges keep their colour but are always at
  least 4.5:1 on their own fill, which they were not in the light themes.
- Syntax highlighting restarts at every hunk, so a hunk that begins inside a block comment or
  string no longer colours the hunks after it.

### Changed

- Releases are numbered builds, named by `git rev-list --count` of their commit on `main` and its
  short hash (`build 412 (a1b2c3d)`), instead of semantic versions. The number is shown in About,
  `canopy --version`, the logs and the update check; the update check, the one-line installers
  (`--version N`) and the update feed compare builds as integers, and a version such as
  `0.2.1-beta.1` counts as older than every build. Nothing is committed or bumped to release: the
  Create release workflow tags `build-N`. Installations older than the first numbered build do
  not understand the new feed: their update check reports an error until Canopy is reinstalled with
  the one-line installer.
- Compact windows move repository navigation into a menu, adapt pane widths and history columns,
  and scroll tabs and toolbar actions. Shared typography, control outlines and keyboard focus
  indicators are more consistent across themes.
- Screenshot tooling supports native Hyprland capture when Xvfb is unavailable, workspace
  selection and `--zoom` for scaled-layout checks; captures reset saved panel layout.
- Stage all leaves out a folder that holds its own Git repository instead of adding it as a
  submodule entry.
- A new branch never tracks its start point on its own (pushing sets the upstream), and a branch
  or start point whose name begins with `-` is refused instead of being read by git as an option.
- Interface transitions are shorter (150 ms instead of 180 ms), in line with the new motion
  tokens.
- After accepting the Privacy Policy and Terms on first run, start-up notices and the update
  check now start without a restart.
- `~` in clone and init destinations and opened paths expands to the home folder.
- A repository, clone or update thread that fails to start reports an error instead of loading
  forever.
- Smooth with huge repositories and many tabs: frames no longer copy the snapshot, diff or
  conflict file; long sidebar, file and request lists draw only the rows in view; the diff keeps
  its layout and scrolls a 50,000-line diff as cheaply as a short one; the conflict resolver
  skips cards out of view; syntax highlighting runs on its own threads; the command palette
  builds its entries once per opening.

<!-- release: canopy-v0.2.1-beta.1 2026-10-01T21:37:51Z -->
## Canopy v0.2.1-beta.1 (1 October 2026)

### Added

- GitHub and GitLab (self-hosted GitLab included): forge icons on remotes, "Open on" links for
  commits, branches and remotes, and a pull and merge request view with checks, reviews and the
  conversation, plus create, check out, comment, approve, merge and close, through the host's REST
  API with a token you provide (Settings → Accounts, kept per host and port; an environment
  variable or git's credential helper also works). Requests can be turned off in Settings →
  Integrations.
- Local-only repositories show a "local only" badge, and Publish adds a remote and pushes. The
  clone and add-remote dialogs build the address from `owner/repo` with an HTTPS or SSH choice.
- Seven themes (Midnight, Daylight, Aurora, Ember, Neon, Forest and Paper), interface zoom, reduced
  motion and a settings screen (Ctrl+,) for appearance, Git, integrations, accounts, updates and
  privacy. Every option applies at once.
- A keyboard map in one table: palette, a searchable cheatsheet (`?` or Ctrl+/), vim motions and
  single-key Git actions, never Super and never while typing. `docs/keybindings.md` lists it.
- Credential and SSH passphrase prompts, and host-key questions, in Canopy's own dialog instead of
  failing, whenever git or ssh needs one.
- Staging, unstaging and discarding single lines of a hunk, side-by-side diffs, syntax highlighting,
  and context-line and whitespace options for diffs, global or per repository.
- A three-way conflict resolver (ours, theirs, both, the common ancestor or an edit by hand), and
  merge modes: default, no fast-forward, fast-forward only and squash.
- Each repository tab shows its commits to push and pull.
- An update check against Canopy's own feed, a "What's new" dialog after an upgrade, and the option
  to turn the check off.
- Structured JSON-lines logs per run and local crash reports in Canopy's data folder, with Settings
  → Copy diagnostics. Opt-in, scrubbed crash reports to NecturaLabs, asked on first start together
  with the Terms of Service and Privacy Policy, which can be read in the app.
- SVG illustrations for the empty states and the welcome screen (placeholders until the final
  art).
- One-line installers for Linux and macOS (`curl -fsSL …/canopy/install.sh | sh`) and Windows
  (`irm …/canopy/install.ps1 | iex`): per-user, no sudo, a folder of Canopy's own, SHA-256
  checked downloads, in-place upgrades and a clean uninstall. macOS builds are now a
  `Canopy.app` bundle.

### Security

- Files Canopy reads or writes inside a repository (the conflict resolver) refuse paths that leave
  the working tree, name `.git`, or cross a symbolic link; a conflicted file behind a symlinked
  folder now gives an error instead of opening.
- A credential or host-key prompt can no longer be replaced or dropped by another dialog; dialogs
  queue behind it, and Escape on a host-key question answers "no".
- Crash reports also scrub credentials in every URL, GitHub and GitLab token patterns, `Bearer`
  values, and home folders only at whole-path boundaries.
- Saved hosting tokens are kept per host and port, so a GitLab instance on another port no longer
  shares a token with the default one.
- Programs Canopy opens (terminal, editor, browser) never inherit the credential prompt's secret.
- The installers' test-only feed override accepts nothing but a loopback host and a port, so a
  value such as `http://127.0.0.1:1@elsewhere.example` is refused. `install.ps1` follows
  redirects itself and refuses any that is not HTTPS; `install.sh` ignores `~/.curlrc` and
  `~/.wgetrc`.
- The installers never write through a symlink or over a desktop entry, icon, Start Menu shortcut
  or Apps & features entry that another install owns, and `--purge` deletes a generically named
  folder (`canopy`) only when it is marked as Canopy's (`.canopy-data`) or holds Canopy's own
  files.

### Fixed

- Commit details restore a readable height after a small window is enlarged. Expand and a
  compact History/Commit details switch give the author, changed files and diff useful space.
  A shorter initial pane leaves less empty space under short diffs.
- History search now appears only when invoked with Ctrl+F or `/`; those shortcuts, Esc and the
  close button hide it and restore the full graph. The redundant commit count and status-bar
  repository path are removed.
- Commit detail Expand and Back sit at the right end of the filename row instead of adding another
  header row. Ref and request pills use clearer color fills and legible text; opened context submenu
  items match hovered menu items rather than flashing purple.

- Interface zoom no longer moves the Settings slider during a drag; percentage entry now parses
  correctly; increasing zoom no longer increases the native window minimum size.
- Clone destination validation runs off the UI thread and keeps the entered values on failure.
- Native folder selection keeps the app event loop running while browsing instead of causing
  operating-system unresponsive warnings.
- Compact settings, legal text, shortcuts, palette, diff controls and history labels stay within
  their viewport; long paths no longer overlap status counts.
- Staging, unstaging and discarding use each path literally: a file named `*` or `[ab].txt` no
  longer touches other files (discarding an untracked `[ab].txt` used to delete an untracked
  `b.txt` too).
- Deleting a branch from the sidebar runs `git branch -d`: a branch with unmerged commits is no
  longer deleted silently, and Canopy asks before forcing it.
- Opening a large repository no longer freezes the window: the repository is opened and its file
  watcher set up off the UI thread.
- Commits, checkouts and fetches in a linked worktree or submodule now refresh Canopy: their git
  folder (and the shared common folder) is watched too. The watcher no longer follows symbolic
  links.
- Installers: a failed or interrupted (Ctrl+C) upgrade puts the previous version back without
  ever deleting part of it; uninstall removes only the installer's own files and keeps the folder
  when it holds anything else; re-running no longer silently replaces a newer version (such as a
  beta) with an older one; a failed first install leaves no empty folders behind and does not
  claim an existing empty folder; a symlinked home folder no longer breaks uninstall; errors
  during downloads, including a missing `curl` and `wget`, are always shown; a script cut short
  in download runs nothing; and through `irm | iex` the Windows installer leaves the PowerShell
  session as it found it.
- Partial clones (`git clone --filter=blob:none` or `--filter=tree:0`) no longer fail with
  "object not found" when you open an old commit or its diff: Canopy downloads the missing
  objects through your `git` (the status bar says from where) and shows git's own message, with a
  Retry button, when that fails. The commit's file list appears at once, and its line counts
  follow once downloaded (commits over 200 files keep the list without counts). Selecting several
  commits quickly downloads only for the last one. After a soft reset in a treeless clone the
  history still loads, and the Changes view says why it cannot list changes yet instead of
  showing every file as added. A remote whose name looks like a git option is refused, never
  run. Partial clones made by Git before 2.24 get a message with the commands that convert them.
- Secondary and faint text, links, status colours and graph lanes are readable on every surface
  they are drawn on, selected rows and diff lines included, in all seven themes (WCAG AA; body
  text AAA). Selected values in Settings use the same calmer selection fill as lists. Branch and
  tag pills, avatar initials and change and count badges keep their colour but are always at
  least 4.5:1 on their own fill, which they were not in the light themes.
- Syntax highlighting restarts at every hunk, so a hunk that begins inside a block comment or
  string no longer colours the hunks after it.

### Changed

- Compact windows move repository navigation into a menu, adapt pane widths and history columns,
  and scroll tabs and toolbar actions. Shared typography, control outlines and keyboard focus
  indicators are more consistent across themes.
- Screenshot tooling supports native Hyprland capture when Xvfb is unavailable, workspace
  selection and `--zoom` for scaled-layout checks; captures reset saved panel layout.
- Stage all leaves out a folder that holds its own Git repository instead of adding it as a
  submodule entry.
- A new branch never tracks its start point on its own (pushing sets the upstream), and a branch
  or start point whose name begins with `-` is refused instead of being read by git as an option.
- Interface transitions are shorter (150 ms instead of 180 ms), in line with the new motion
  tokens.
- After accepting the Privacy Policy and Terms on first run, start-up notices and the update
  check now start without a restart.
- `~` in clone and init destinations and opened paths expands to the home folder.
- A repository, clone or update thread that fails to start reports an error instead of loading
  forever.
- Smooth with huge repositories and many tabs: frames no longer copy the snapshot, diff or
  conflict file; long sidebar, file and request lists draw only the rows in view; the diff keeps
  its layout and scrolls a 50,000-line diff as cheaply as a short one; the conflict resolver
  skips cards out of view; syntax highlighting runs on its own threads; the command palette
  builds its entries once per opening.

<!-- release: canopy-v0.2.0-beta.1 2026-10-01T14:11:59Z -->
## Canopy v0.2.0-beta.1 (1 October 2026)

### Added

- GitHub and GitLab (self-hosted GitLab included): forge icons on remotes, "Open on" links for
  commits, branches and remotes, and a pull and merge request view with checks, reviews and the
  conversation, plus create, check out, comment, approve, merge and close, through the host's REST
  API with a token you provide (Settings → Accounts, kept per host and port; an environment
  variable or git's credential helper also works). Requests can be turned off in Settings →
  Integrations.
- Local-only repositories show a "local only" badge, and Publish adds a remote and pushes. The
  clone and add-remote dialogs build the address from `owner/repo` with an HTTPS or SSH choice.
- Seven themes (Midnight, Daylight, Aurora, Ember, Neon, Forest and Paper), interface zoom, reduced
  motion and a settings screen (Ctrl+,) for appearance, Git, integrations, accounts, updates and
  privacy. Every option applies at once.
- A keyboard map in one table: palette, a searchable cheatsheet (`?` or Ctrl+/), vim motions and
  single-key Git actions, never Super and never while typing. `docs/keybindings.md` lists it.
- Credential and SSH passphrase prompts, and host-key questions, in Canopy's own dialog instead of
  failing, whenever git or ssh needs one.
- Staging, unstaging and discarding single lines of a hunk, side-by-side diffs, syntax highlighting,
  and context-line and whitespace options for diffs, global or per repository.
- A three-way conflict resolver (ours, theirs, both, the common ancestor or an edit by hand), and
  merge modes: default, no fast-forward, fast-forward only and squash.
- Each repository tab shows its commits to push and pull.
- An update check against Canopy's own feed, a "What's new" dialog after an upgrade, and the option
  to turn the check off.
- Structured JSON-lines logs per run and local crash reports in Canopy's data folder, with Settings
  → Copy diagnostics. Opt-in, scrubbed crash reports to NecturaLabs, asked on first start together
  with the Terms of Service and Privacy Policy, which can be read in the app.
- SVG illustrations for the empty states and the welcome screen (placeholders until the final
  art).
- One-line installers for Linux and macOS (`curl -fsSL …/canopy/install.sh | sh`) and Windows
  (`irm …/canopy/install.ps1 | iex`): per-user, no sudo, a folder of Canopy's own, SHA-256
  checked downloads, in-place upgrades and a clean uninstall. macOS builds are now a
  `Canopy.app` bundle.

### Security

- Files Canopy reads or writes inside a repository (the conflict resolver) refuse paths that leave
  the working tree, name `.git`, or cross a symbolic link; a conflicted file behind a symlinked
  folder now gives an error instead of opening.
- A credential or host-key prompt can no longer be replaced or dropped by another dialog; dialogs
  queue behind it, and Escape on a host-key question answers "no".
- Crash reports also scrub credentials in every URL, GitHub and GitLab token patterns, `Bearer`
  values, and home folders only at whole-path boundaries.
- Saved hosting tokens are kept per host and port, so a GitLab instance on another port no longer
  shares a token with the default one.
- Programs Canopy opens (terminal, editor, browser) never inherit the credential prompt's secret.
- The installers' test-only feed override accepts nothing but a loopback host and a port, so a
  value such as `http://127.0.0.1:1@elsewhere.example` is refused. `install.ps1` follows
  redirects itself and refuses any that is not HTTPS; `install.sh` ignores `~/.curlrc` and
  `~/.wgetrc`.
- The installers never write through a symlink or over a desktop entry, icon, Start Menu shortcut
  or Apps & features entry that another install owns, and `--purge` deletes a generically named
  folder (`canopy`) only when it is marked as Canopy's (`.canopy-data`) or holds Canopy's own
  files.

### Fixed

- Staging, unstaging and discarding use each path literally: a file named `*` or `[ab].txt` no
  longer touches other files (discarding an untracked `[ab].txt` used to delete an untracked
  `b.txt` too).
- Deleting a branch from the sidebar runs `git branch -d`: a branch with unmerged commits is no
  longer deleted silently, and Canopy asks before forcing it.
- Opening a large repository no longer freezes the window: the repository is opened and its file
  watcher set up off the UI thread.
- Commits, checkouts and fetches in a linked worktree or submodule now refresh Canopy: their git
  folder (and the shared common folder) is watched too. The watcher no longer follows symbolic
  links.
- Installers: a failed or interrupted (Ctrl+C) upgrade puts the previous version back without
  ever deleting part of it; uninstall removes only the installer's own files and keeps the folder
  when it holds anything else; re-running no longer silently replaces a newer version (such as a
  beta) with an older one; a failed first install leaves no empty folders behind and does not
  claim an existing empty folder; a symlinked home folder no longer breaks uninstall; errors
  during downloads, including a missing `curl` and `wget`, are always shown; a script cut short
  in download runs nothing; and through `irm | iex` the Windows installer leaves the PowerShell
  session as it found it.
- Partial clones (`git clone --filter=blob:none` or `--filter=tree:0`) no longer fail with
  "object not found" when you open an old commit or its diff: Canopy downloads the missing
  objects through your `git` (the status bar says from where) and shows git's own message, with a
  Retry button, when that fails. The commit's file list appears at once, and its line counts
  follow once downloaded (commits over 200 files keep the list without counts). Selecting several
  commits quickly downloads only for the last one. After a soft reset in a treeless clone the
  history still loads, and the Changes view says why it cannot list changes yet instead of
  showing every file as added. A remote whose name looks like a git option is refused, never
  run. Partial clones made by Git before 2.24 get a message with the commands that convert them.
- Secondary and faint text, links, status colours and graph lanes are readable on every surface
  they are drawn on, selected rows and diff lines included, in all seven themes (WCAG AA; body
  text AAA). Selected values in Settings use the same calmer selection fill as lists. Branch and
  tag pills, avatar initials and change and count badges keep their colour but are always at
  least 4.5:1 on their own fill, which they were not in the light themes.
- Syntax highlighting restarts at every hunk, so a hunk that begins inside a block comment or
  string no longer colours the hunks after it.

### Changed

- Stage all leaves out a folder that holds its own Git repository instead of adding it as a
  submodule entry.
- A new branch never tracks its start point on its own (pushing sets the upstream), and a branch
  or start point whose name begins with `-` is refused instead of being read by git as an option.
- Interface transitions are shorter (150 ms instead of 180 ms), in line with the new motion
  tokens.
- After accepting the Privacy Policy and Terms on first run, start-up notices and the update
  check now start without a restart.
- `~` in clone and init destinations and opened paths expands to the home folder.
- A repository, clone or update thread that fails to start reports an error instead of loading
  forever.
- Smooth with huge repositories and many tabs: frames no longer copy the snapshot, diff or
  conflict file; long sidebar, file and request lists draw only the rows in view; the diff keeps
  its layout and scrolls a 50,000-line diff as cheaply as a short one; the conflict resolver
  skips cards out of view; syntax highlighting runs on its own threads; the command palette
  builds its entries once per opening.
