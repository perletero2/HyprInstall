#!/usr/bin/env bash
# Post-install configuration script
# Sets up noctalia-greeter and default file manager
# Called with: sudo bash lib/post_install.sh

set -euo pipefail

# Determine script directory for sourcing helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global.sh"

# --------------------------------------------------- // Noctalia-greeter setup
setup_greeter() {
	print_log -stat "GREETD" "Setting up noctalia-greeter..."

	# Create greeter system user (skip if already exists)
	if ! sudo useradd -r -s /usr/bin/nologin -d /var/lib/noctalia-greeter greeter 2>/dev/null; then
		print_log -y "[USER]  " -wt "Greeter user already exists. Continuing..."
	else
		print_log -g "[USER]  " -wt "Greeter user created."
	fi

	# Backup existing greetd config if present
	if sudo test -f /etc/greetd/config.toml 2>/dev/null; then
		sudo cp -a /etc/greetd/config.toml /etc/greetd/config.toml.bak
		print_log -g "[BACKUP] Greetd config backed up."
	else
		print_log -y "[SKIP]  " -wt "No existing greetd config to backup."
	fi

	# Write greetd configuration
	if sudo tee /etc/greetd/config.toml >/dev/null <<'GREETD_CONFIG'
[terminal]
vt = 1

[default_session]
command = "/usr/bin/noctalia-greeter-session"
user = "greeter"
GREETD_CONFIG
	then
		print_log -g "[CONFIG] Greetd config written."
	else
		print_log -err "[FAIL]  " -r "Failed to write greetd config. Check permissions."
		return 1
	fi

	# Enable greetd service
	if sudo systemctl enable greetd; then
		print_log -g "[SERVICE] greetd enabled."
	else
		print_log -y "[WARN]  " -wt "Failed to enable greetd service. Run 'sudo systemctl enable greetd' manually."
	fi

	print_log -g "Noctalia-greeter setup complete!"
}

# --------------------------------------------------- // Dolphin default file manager
setup_dolphin() {
	if ! pkg_installed dolphin; then
		print_log -y "[SKIP]  " -wt "Dolphin not installed. Skipping file manager config."
		return 0
	fi

	if ! pkg_installed xdg-utils; then
		print_log -y "[SKIP]  " -wt "xdg-utils not installed. Skipping file manager config."
		return 0
	fi

	print_log -stat "FILEMGR" "Setting dolphin as default file manager..."
	xdg-mime default org.kde.dolphin.desktop inode/directory
	local current_default
	current_default="$(xdg-mime query default inode/directory)"
	print_log -g "[FILEMGR] " -wt "Default file explorer set to: $current_default"
}

# --------------------------------------------------- // Main
main() {
	print_log -g ""
	print_log -g "=========================================="
	print_log -g "   Post-Install Configuration"
	print_log -g "=========================================="
	print_log ""

	setup_greeter
	setup_dolphin

	print_log -g ""
	print_log -g "=========================================="
	print_log -g "   Post-install complete!"
	print_log -g "=========================================="
	print_log ""
}

main
