#!/usr/bin/env bash

# Shared helper functions for the Hyprland install script
# Sourced by install.sh and lib/post_install.sh

# Colored console output
# Usage: print_log [-r|-g|-y|-b|-c|-m|-wt|-n|-stat|-warn|-err] "message"
print_log() {
	while (("$#")); do
		case "$1" in
		-r)
			echo -ne "\e[31m$2\e[0m"
			shift 2
			;; # Red
		-g)
			echo -ne "\e[32m$2\e[0m"
			shift 2
			;; # Green
		-y)
			echo -ne "\e[33m$2\e[0m"
			shift 2
			;; # Yellow
		-b)
			echo -ne "\e[34m$2\e[0m"
			shift 2
			;; # Blue
		-m)
			echo -ne "\e[35m$2\e[0m"
			shift 2
			;; # Magenta
		-c)
			echo -ne "\e[36m$2\e[0m"
			shift 2
			;; # Cyan
		-wt)
			echo -ne "\e[37m$2\e[0m"
			shift 2
			;; # White
		-n)
			echo -ne "\e[96m$2\e[0m"
			shift 2
			;; # Neon
		-stat)
			echo -ne "\e[30;46m $2 \e[0m :: "
			shift 2
			;; # Status
		-warn)
			echo -ne "WARNING :: \e[30;43m $2 \e[0m :: "
			shift 2
			;; # Warning
		-err)
			echo -ne "ERROR :: \e[4;31m$2 \e[0m"
			shift 2
			;; # Error
		*)
			echo -ne "$1"
			shift
			;;
		esac
	done
	echo ""
}

# Check if a package is installed
# Usage: pkg_installed <package_name>
# Returns: 0 if installed, 1 if not
pkg_installed() {
	pacman -Q "$1" &>/dev/null
}

# Interactive yes/no confirmation prompt
# Usage: confirm "Question?"
# Returns: 0 if yes, 1 if no
confirm() {
	local question="${1:-Continue?}"
	local response
	while true; do
		print_log -b "[CONFIRM] " -wt "$question [Y/n] "
		read -r response
		case "$response" in
		[Yy] | "") return 0 ;;
		[Nn]) return 1 ;;
		*) print_log -y "Please answer yes or no." ;;
		esac
	done
}

# Read a package list file and return clean package names (strips comments and blank lines)
# Usage: read_package_list <filepath>
# Prints one package name per line
read_package_list() {
	local filepath="$1"
	if [[ ! -f "$filepath" ]]; then
		print_log -err "Package list file not found: $filepath"
		return 1
	fi
	while IFS= read -r line; do
		# Strip inline comments (everything after #)
		line="${line%%#*}"
		# Trim whitespace
		line="$(echo "$line" | xargs)"
		# Skip empty lines
		[[ -z "$line" ]] && continue
		echo "$line"
	done <"$filepath"
}
