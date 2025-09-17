# Dotfiles and System Configuration

This repository contains dotfiles and system configurations organized using GNU Stow packages for easy deployment across fresh OpenMandriva installations.

## Structure

This uses the traditional GNU Stow package structure, where each directory represents a logical package:

```
~/stow/
├── shell/           # Shell configurations (.bashrc, .zshrc)
├── zsh/             # Zsh framework (.oh-my-zsh)
├── app-configs/     # Application configs (.config directory)
├── conky/           # Conky desktop widgets
├── local/           # Local binaries (.local directory)
├── pictures/        # Personal pictures and wallpapers
└── sddm-theme/      # SDDM login theme (system-level)
```

## Packages Overview

### User-Level Packages
- **shell**: Basic shell configurations (bash, zsh)
- **zsh**: Oh-My-Zsh framework and customizations
- **app-configs**: Application configurations (.config directory)
  - Kitty terminal
  - Ghostty terminal
  - Fastfetch system info
  - Micro editor
  - Espanso text expander
- **conky**: Desktop widget themes and configurations
- **local**: Local user binaries and scripts
- **pictures**: Personal images, logos, and wallpapers

### System-Level Packages
- **sddm-theme**: SDDM Sugar Candy login theme

## Quick Installation (All Packages)

For a complete setup on a fresh installation:

```bash
# Clone the repository
git clone <your-repo-url> ~/stow

# Install all user-level packages
cd ~/stow
stow shell zsh app-configs conky local pictures

# Install system-level packages (requires sudo)
sudo stow -t / sddm-theme

# Configure SDDM to use the theme
sudo tee /etc/sddm.conf << EOF
[Theme]
Current=sugar-candy
EOF
```

## Selective Installation

Install only specific packages as needed:

```bash
cd ~/stow

# Basic shell setup
stow shell zsh

# Application configurations
stow app-configs

# Desktop widgets
stow conky

# Personal files
stow pictures

# System theme (requires sudo)
sudo stow -t / sddm-theme
```

## Package Management

### Installing a Package
```bash
cd ~/stow
stow <package-name>
```

### Removing a Package
```bash
cd ~/stow
stow -D <package-name>
```

### Updating a Package
```bash
cd ~/stow
stow -R <package-name>  # Restow (remove and install)
```

## Fresh Installation Script

For automated deployment, you can use this script pattern:

```bash
#!/bin/bash
set -e

# Clone dotfiles
git clone <your-repo-url> ~/stow

# Install user packages
cd ~/stow
stow shell zsh app-configs conky local pictures

# Install system packages
sudo stow -t / sddm-theme

# Configure SDDM
if [ ! -f /etc/sddm.conf ]; then
    sudo tee /etc/sddm.conf << EOF
[Theme]
Current=sugar-candy
EOF
else
    sudo sed -i '/\[Theme\]/,/^\[/ s/Current=.*/Current=sugar-candy/' /etc/sddm.conf
fi

echo "Dotfiles installation complete!"
```

## Customization

### Adding New Configurations

1. Add files to the appropriate package directory
2. If it's a new type of configuration, create a new package:
   ```bash
   mkdir ~/stow/new-package
   # Add your files maintaining the home directory structure
   ```

### SDDM Theme Customization

Edit theme files in the package:
- Main config: `sddm-theme/usr/share/sddm/themes/sugar-candy/theme.conf`
- User overrides: `sddm-theme/usr/share/sddm/themes/sugar-candy/theme.conf.user`

Changes take effect immediately through the symlinks.

## Testing

Test package installation without making changes:
```bash
cd ~/stow
stow --simulate --verbose <package-name>
```

## Requirements

- GNU Stow
- Git
- sudo access (for system-level packages)

## Notes

- User packages install to your home directory
- System packages require sudo and install to root filesystem
- All configurations are symlinked, so changes in the repo are immediately active
- This structure is compatible with standard stow workflows and tools