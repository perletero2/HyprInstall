#!/usr/bin/env bash
# shellcheck disable=SC1091

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global.sh"

# Noctalia-greeter config
noctalia_greeter() {

	if pkg_installed sddm; then
		print_log -g "Setting up noctalia-greeter..."

		if ! sudo useradd -r -s /usr/bin/nologin -d /var/lib/noctalia-greeter greeter 2>/dev/null; then
			print_log -y "User 'greeter' already exists or failed to create. Continuing..."
		fi

		if ! sudo cp -a /etc/greetd/config.toml /etc/greetd/config.toml.bak 2>/dev/null; then
			print_log -y "Failed to backup greetd config. Continuing..."
		fi

		if ! sudo tee /etc/greetd/config.toml >/dev/null <<'GREETD_CONFIG'
[terminal]
vt = 1

[default_session]
command = "/usr/bin/noctalia-greeter-session"
user = "greeter"
GREETD_CONFIG
		then
			print_log -r "Failed to write greetd config. Check permissions."
			return 1
		fi

		if ! sudo systemctl enable greetd; then
			print_log -y "Failed to enable greetd service. Run 'sudo systemctl enable greetd' manually. Check you don't already have a login manager enabled."
		fi

		print_log -g "Noctalia-greeter setup complete!"

	fi
}

# dolphin
dolphin() {
	if pkg_installed dolphin && pkg_installed xdg-utils; then
		print_log -c "[FILEMANAGER] " -b "detected :: " "dolphin"
		xdg-mime default org.kde.dolphin.desktop inode/directory
		print_log -g "[FILEMANAGER] " -b " :: " "setting $(xdg-mime query default "inode/directory") as default file explorer..."
	fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main() {
		print_log -g "Starting post-install configuration ..."

		noctalia_greeter
		dolphin
	}
	main
fi
