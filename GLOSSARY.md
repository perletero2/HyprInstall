# Glossary

## noctalia

A shell running on top of Hyprland that provides bars, system tray, widgets, and other desktop enhancements. Installed from the official Arch Linux repositories.

## noctalia-greeter

A fork of greeterd designed to work as a login manager with noctalia. Shares themes and parameters with noctalia. Installed from the AUR.

## stow

GNU Stow — a symlink farm manager. Used to deploy dotfiles from a source directory (e.g., `~/dotfiles`) to their target locations under `~` using `stow . --adopt`.

## dotfiles repo

The user's personal configuration repository (https://github.com/perletero2/Hyprland-Dotfiles), containing `.config/`, `.scripts/`, `.custom/` — all deployed via stow.

## Hyprland

A dynamic tiling Wayland compositor. The target desktop environment for this installation script.

## EndeavourOS

An Arch Linux-based distribution. The base OS; the install script runs on top of an already-installed EndeavourOS system.

## Nerd Fonts

Patched fonts from https://github.com/ryanoasis/nerd-fonts that include icon glyphs for terminal emulators, status bars, and editors. Downloaded directly from GitHub releases.

## post_install.sh

The post-install configuration script (in `lib/`) that sets up noctalia-greeter (greetd config file, greeter user) and configures default applications (dolphin). Requires sudo for system-level changes.

## icon theme

The yet-another-monochrome-icon-set, a monochrome icon theme downloaded from Bitbucket and installed to `~/.local/share/icons/`.

## core packages

Packages installed via `pacman` that are essential for Hyprland to function: compositor, audio, display, shell, WM tools, theming, browsers, editors.

## AUR packages

Packages from the Arch User Repository installed via `yay`: noctalia-greeter, wlogout, Vesktop, Powerlevel10k, etc.

## extra packages

Optional packages that can be added by the user before running the script: games, password managers, media tools, etc.
