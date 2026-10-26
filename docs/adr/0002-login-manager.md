# ADR-0002: Use noctalia-greeter for login

## Context

Traditional display managers like SDDM are deprecated or unnecessary for Wayland compositors. We need a login manager for the Hyprland installation.

## Decision

Use **noctalia-greeter** (a fork of greeterd) as the login manager. A dedicated `greeter` system user is created with a nologin shell, and the greetd configuration file (`/etc/greetd/config.toml`) is set up to launch noctalia-greeter on VT1. The greeter config file and noctalia-greeter share themes and parameters.

## Consequences

- **Positive**: Lightweight, Wayland-native, no SDDM dependency; shares themes with noctalia desktop shell.
- **Negative**: Requires manual configuration of the greetd config file; fewer themes and community resources compared to SDDM.
