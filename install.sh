#!/usr/bin/env bash
# Hyprland Install Script for EndeavourOS
# Automates Hyprland desktop setup on a fresh EndeavourOS installation

set -euo pipefail

# Determine script directory for sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helpers
source "$SCRIPT_DIR/lib/global.sh"

# --------------------------------------------------- // Configuration
DOTFILES_REPO="https://github.com/perletero2/Hyprland-Dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
FONTS_DIR="$HOME/.local/share/fonts"
ICONS_DIR="$HOME/.local/share/icons"

# --------------------------------------------------- // Menu
show_menu() {
	print_log -g "=========================================="
	print_log -g "   Hyprland Install Script"
	print_log -g "=========================================="
	print_log ""
	print_log -y "  1) Full Install  " -wt " — packages + dotfiles + fonts/icons + post-install"
	print_log -y "  2) Packages Only" -wt " — packages + post-install (skip dotfiles, fonts, icons)"
	print_log -y "  3) Dotfiles Only" -wt " — dotfiles + fonts/icons (skip packages)"
	print_log ""
}

# --------------------------------------------------- // Package Installation
install_packages() {
	local category="$1"
	local list_file="$2"
	local helper="$3" # "pacman" or "yay"

	print_log -b ""
	print_log -stat "INSTALLING" "$category packages from $list_file"

	# Read package list
	local packages=()
	while IFS= read -r pkg; do
		packages+=("$pkg")
	done < <(read_package_list "$list_file")

	local total=${#packages[@]}
	local installed=0

	if [[ $total -eq 0 ]]; then
		print_log -y "No packages to install in $category."
		return 0
	fi

	for pkg in "${packages[@]}"; do
		progress_bar "$installed" "$total"

		if pkg_installed "$pkg"; then
			print_log -g "[SKIP]  " -wt "$pkg (already installed)"
		else
			if [[ "$helper" == "yay" ]]; then
				if yay -S --noconfirm "$pkg" 2>&1; then
					print_log -g "[OK]    " -wt "$pkg"
					installed=$((installed + 1))
				else
					print_log -err "[FAIL]  " -r "$pkg — Try: yay -S $pkg manually"
				fi
			elif sudo "$helper" -S --noconfirm "$pkg" 2>&1; then
				print_log -g "[OK]    " -wt "$pkg"
				installed=$((installed + 1))
			else
				print_log -err "[FAIL]  " -r "$pkg — Try: sudo $helper -S $pkg manually"
			fi
		fi
	done

	progress_bar "$installed" "$total"
	print_log -g "Done installing $category packages."
}

# --------------------------------------------------- // Dotfiles
clone_and_stow_dotfiles() {
	print_log -b ""
	print_log -stat "DOTFILES" "Cloning dotfiles repo..."

	if [[ -d "$DOTFILES_DIR" ]]; then
		print_log -y "Dotfiles repo already exists at $DOTFILES_DIR"
		confirm "Re-clone the dotfiles repo?" || return 0
	fi

	git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
	print_log -g "Dotfiles cloned to $DOTFILES_DIR"

	# Ask which modules to stow
	print_log -b ""
	if confirm "Stow all modules (.config/, .scripts/, .custom/)?"; then
		print_log -stat "STOW" "Stowing all modules..."
		cd "$DOTFILES_DIR"
		stow . --adopt
		print_log -g "All modules stowed successfully."
	else
		print_log -stat "STOW" "Selecting individual modules..."
		cd "$DOTFILES_DIR"
		for module in */; do
			module="${module%/}"
			if confirm "Stow $module?"; then
				stow "$module" --adopt
				print_log -g "Stowed $module"
			fi
		done
	fi

	cd "$SCRIPT_DIR"
}

# --------------------------------------------------- // Fonts
install_fonts() {
	print_log -b ""
	print_log -stat "FONTS" "Installing Nerd Fonts..."

	mkdir -p "$FONTS_DIR"

	# JetBrains Mono
	local font_name="JetBrainsMono"
	local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"
	local font_dir="$FONTS_DIR/${font_name}"

	if [[ -d "$font_dir" && -f "$font_dir/OTF/JetBrainsMono*.otf" ]]; then
		print_log -y "JetBrains Mono Nerd Font already installed."
	else
		print_log -stat "FONTS" "Downloading $font_name..."
		curl -fSL "$font_url" -o "/tmp/${font_name}.tar.xz"
		mkdir -p "$font_dir"
		tar -xf "/tmp/${font_name}.tar.xz" -C "$font_dir" --strip-components=2
		rm "/tmp/${font_name}.tar.xz"
		print_log -g "Installed $font_name to $font_dir"
	fi

	# Hack
	font_name="Hack"
	font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"
	font_dir="$FONTS_DIR/${font_name}"

	if [[ -d "$font_dir" && -f "$font_dir/OTF/Hack*.otf" ]]; then
		print_log -y "Hack Nerd Font already installed."
	else
		print_log -stat "FONTS" "Downloading $font_name..."
		curl -fSL "$font_url" -o "/tmp/${font_name}.tar.xz"
		mkdir -p "$font_dir"
		tar -xf "/tmp/${font_name}.tar.xz" -C "$font_dir" --strip-components=2
		rm "/tmp/${font_name}.tar.xz"
		print_log -g "Installed $font_name to $font_dir"
	fi

	# Refresh font cache
	print_log -stat "FONTS" "Refreshing font cache..."
	fc-cache -fv >/dev/null 2>&1
	print_log -g "Font cache refreshed."
}

# --------------------------------------------------- // Icon Theme
install_icon_theme() {
	print_log -b ""
	print_log -stat "ICONS" "Installing icon theme..."

	mkdir -p "$ICONS_DIR"

	if [[ -d "$ICONS_DIR/yet-another-monochrome-icon-set" ]]; then
		print_log -y "Icon theme already installed."
		confirm "Re-clone the icon theme?" || return 0
	fi

	git clone "https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set.git" "$ICONS_DIR/yet-another-monochrome-icon-set"
	print_log -g "Icon theme installed to $ICONS_DIR/yet-another-monochrome-icon-set"
}

# --------------------------------------------------- // Post-install
run_post_install() {
	print_log -b ""
	print_log -stat "POST-INSTALL" "Running post-install configuration..."
	sudo bash "$SCRIPT_DIR/lib/post_install.sh"
	print_log -g "Post-install configuration complete."
}

# --------------------------------------------------- // Main
main() {
	show_menu

	# Get user choice
	local choice
	print_log -b "[MENU] " -wt "Select installation mode: "
	read -r choice

	case "$choice" in
	1) # Full Install
		# Packages
		if confirm "Install core packages?"; then
			install_packages "Core" "$SCRIPT_DIR/packages/core.lst" "pacman"
		fi
		if confirm "Install AUR packages?"; then
			install_packages "AUR" "$SCRIPT_DIR/packages/aur.lst" "yay"
		fi
		if confirm "Install extra packages?"; then
			install_packages "Extra" "$SCRIPT_DIR/packages/extra.lst" "pacman"
		fi
		# Dotfiles
		if confirm "Install dotfiles, fonts, and icon theme?"; then
			clone_and_stow_dotfiles
			install_fonts
			install_icon_theme
		fi
		# Post-install
		run_post_install
		;;

	2) # Packages Only
		if confirm "Install core packages?"; then
			install_packages "Core" "$SCRIPT_DIR/packages/core.lst" "pacman"
		fi
		if confirm "Install AUR packages?"; then
			install_packages "AUR" "$SCRIPT_DIR/packages/aur.lst" "yay"
		fi
		if confirm "Install extra packages?"; then
			install_packages "Extra" "$SCRIPT_DIR/packages/extra.lst" "pacman"
		fi
		# Post-install
		run_post_install
		;;

	3) # Dotfiles Only
		if confirm "Install dotfiles, fonts, and icon theme?"; then
			clone_and_stow_dotfiles
			install_fonts
			install_icon_theme
		fi
		;;

	*)
		print_log -err "Invalid option: $choice"
		print_log -y "Please run the script again and select 1, 2, or 3."
		exit 1
		;;
	esac

	print_log -g ""
	print_log -g "=========================================="
	print_log -g "   Installation complete!"
	print_log -g "   Reboot to start Hyprland."
	print_log -g "=========================================="
	print_log -g ""
}

main
