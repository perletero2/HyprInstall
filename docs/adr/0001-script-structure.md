# ADR-0001: Script structure and package categorization

## Context

We need a bash script to automate Hyprland installation on EndeavourOS. The script must handle packages, dotfiles, fonts, and post-install configuration in a clean, maintainable way.

## Decision

We chose a **flat-but-organized** structure:

- `install.sh` at the root (main entry point)
- `lib/` for helper scripts (`global.sh`, `post_install.sh`)
- `packages/` for categorized package lists (`core.lst`, `aur.lst`, `extra.lst`)

Packages are split into three categories:

- **Core**: essential packages via `pacman`
- **AUR**: packages from the Arch User Repository via `yay`
- **Extra**: optional packages the user can edit before running

Package list files support inline comments (text after `#` on each line). The script strips comments when reading the lists.

Nerd Fonts are downloaded directly from GitHub releases rather than using AUR packages.

Dotfiles are cloned to `~/dotfiles` and deployed via GNU Stow.

## Consequences

- **Positive**: Clear separation of concerns; easy to add/remove packages; reusable helper functions; no unnecessary AUR dependencies for fonts.
- **Negative**: The script depends on `curl`, `stow`, and `yay` being available at runtime.
