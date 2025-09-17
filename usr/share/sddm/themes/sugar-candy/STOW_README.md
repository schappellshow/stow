# SDDM Sugar Candy Theme - Stow Package

This directory contains the SDDM Sugar Candy theme packaged for GNU Stow deployment.

## What's Included

- Complete SDDM Sugar Candy theme files
- All QML components and configuration files
- Proper stow directory structure

## Installation

From your stow directory (`~/stow`):

```bash
# Install the theme
stow sddm-sugar-candy

# Or if you want to install from the specific theme directory
stow usr/share/sddm/themes/sugar-candy
```

## Configuration

After installation, configure SDDM to use the theme by editing `/etc/sddm.conf`:

```ini
[Theme]
Current=sugar-candy
```

## Testing

Test the theme without logging out:

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/sugar-candy
```

## Customization

Edit the theme configuration files:
- `theme.conf` - Main configuration
- `theme.conf.user` - User overrides (recommended)

## Notes

- This theme requires SDDM >= 0.18 and Qt5 >= 5.11
- Binary assets (images, SVGs) are included in their respective directories
- The theme is fully functional and ready for use
