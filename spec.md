# Spec: Hyprland Install Script for EndeavourOS

## Problem Statement

Setting up a complete Hyprland desktop environment on a fresh EndeavourOS installation requires manually installing dozens of packages, cloning and configuring dotfiles, installing Nerd Fonts, configuring a login manager, and setting up default applications. This process is error-prone, time-consuming, and must be repeated whenever reinstalling.

## Solution

A single bash script (`install.sh`) that automates the entire Hyprland setup on EndeavourOS, with an interactive menu at startup to choose between three installation modes:

- **Full Install**: everything — packages, dotfiles, fonts, icons, post-install configuration
- **Packages Only**: install core + AUR packages and run post-install configuration (for reinstalling packages on an existing system)
- **Dotfiles Only**: clone dotfiles repo, stow them, install fonts and icon theme (for restoring configuration)

## User Stories

1. As a fresh EndeavourOS user, I want to run a single script from the terminal, so that my entire Hyprland desktop is set up without manual intervention.

2. As a user who has already run the script once, I want to reinstall only the packages without re-cloning dotfiles, so that I can recover from a package breakage without losing my configuration.

3. As a user who has lost their dotfiles but kept their packages, I want to restore only the dotfiles and fonts, so that my desktop looks and behaves the same again.

4. As a user, I want the script to install core packages via `pacman` and AUR packages via `yay`, so that all dependencies are satisfied regardless of source.

5. As a user, I want to be able to edit the package lists before running the script, so that I can add or remove packages without modifying the script itself.

6. As a user, I want the package lists to include inline comments explaining what each package does, so that I can understand and modify them easily. The script should strip comments during installation.

7. As a user, I want to be able to add extra optional packages (games, media tools) to a separate list, so that they can be installed alongside the core packages with a single command.

8. As a user, I want the dotfiles to be cloned from my GitHub repository and deployed via GNU Stow, so that my configuration is version-controlled and easily auditable.

9. As a user, I want to choose which dotfiles modules to stow (`.config/`, `.scripts/`, `.custom/`), so that I can selectively deploy only the configurations I want.

10. As a user, I want Nerd Fonts (JetBrains Mono, Hack) to be downloaded directly from their GitHub releases and installed to my local fonts directory, so that terminal emulators, status bars, and editors have icon glyphs without depending on AUR font packages.

11. As a user, I want the yet-another-monochrome-icon-set icon theme to be downloaded from Bitbucket and installed to `~/.local/share/icons/`, so that my system icons match my chosen aesthetic.

12. As a user, I want noctalia-greeter to be configured as my login manager automatically, so that I see the noctalia-themed login screen on boot.

13. As a user, I want dolphin to be set as my default file manager via `xdg-mime`, so that file dialogs open with the correct application.

14. As a user, I want the script to show colored progress feedback (green for installed/skipped, red for failed) with a package counter, so that I can see what's happening during a potentially long installation.

15. As a user, I want the script to stop on errors with a helpful hint, so that I know exactly what went wrong and how to fix it.

16. As a user, I want the script to ask for confirmation before each major step, so that I can review and abort if something looks wrong.

17. As a user, I want the post-install configuration (noctalia-greeter setup) to run automatically at the end of the installation, so that I don't need to run a separate script manually.

18. As a user, I want the script to work from a pure TTY without requiring a graphical environment, so that I can run it immediately after a fresh EndeavourOS install.

## Implementation Decisions

- **Script structure**: `install.sh` at root, `lib/global.sh` for shared helpers, `lib/post_install.sh` for post-install configuration, `packages/` for categorized package lists. This follows ADR-0001.
- **Package categorization**: Three separate `.lst` files (`core.lst`, `aur.lst`, `extra.lst`) with one package per line and optional inline comments (after `#`). The script strips comments when reading the lists.
- **Nerd Fonts**: Downloaded directly from `https://github.com/ryanoasis/nerd-fonts/releases/latest/download/<FontName>.tar.xz`, extracted to `~/.local/share/fonts/<FontName>`, then `fc-cache -fv` is run. No AUR font packages.
- **Dotfiles**: Cloned from `https://github.com/perletero2/Hyprland-Dotfiles` to `~/dotfiles`, deployed via `stow . --adopt` from the clone directory.
- **Icon theme**: yet-another-monochrome-icon-set cloned from Bitbucket (`https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set.git`) and installed to `~/.local/share/icons/`.
- **Login manager**: noctalia-greeter (greeterd fork) configured via `/etc/greetd/config.toml`. A `greeter` system user with nologin shell is created. This follows ADR-0002.
- **Menu**: Interactive menu at script start with three options (Full Install, Packages Only, Dotfiles Only). Simple yes/no prompts for stow modules.
- **Error handling**: `set -euo pipefail`, colored output via `print_log`, progress counter for package installation.
- **Privileges**: Only `pacman`, `yay`, and `post_install.sh` (greetd config) require `sudo`. Everything else runs as the current user.
- **Module boundaries**: `install.sh` orchestrates the flow and delegates to `lib/global.sh` functions. `lib/post_install.sh` is a self-contained script called with `sudo`.

## Testing Decisions

- Tests should verify external behavior: correct menu flow, correct package installation order, correct stow invocation, correct greetd config file content.
- The `global.sh` helper functions (`print_log`, `pkg_installed`, `confirm`) should be tested independently.
- Package list files should be validated for correct format (one package per line, comments after `#` stripped, no blank lines).
- No unit tests needed for `post_install.sh` since it requires root and system-level changes.
- Prior art: the existing `post_install.sh` in `lib/` provides a reference implementation for the greetd configuration logic.

## Out of Scope

- GPU driver installation (EndeavourOS handles this).
- Locale and keyboard layout configuration (EndeavourOS handles this).
- System service management (EndeavourOS handles this).
- Wallpaper configuration (handled by dotfiles repo).
- Multi-user support (single user only).
- Rollback or uninstall functionality.
- Network configuration.
- Btrfs-specific features (snapshot management, grub-btrfs, etc.).

## Further Notes

- The script is designed for personal use on a single machine. It assumes EndeavourOS is already installed with a basic user account.
- Package lists should be reviewed and customized before running — the defaults are based on the user's existing setup. Inline comments are preserved for readability.
- The noctalia-greeter post-install step requires `sudo` because it writes to `/etc/greetd/` and creates a system user.
- The script should be idempotent where possible: skipping already-installed packages, reusing existing dotfiles clone.
