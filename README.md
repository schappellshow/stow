# SDDM Sugar Candy Stow Directory

This directory contains the SDDM Sugar Candy theme configured for use with GNU Stow.

## What's Included

- **sugar-candy theme**: Complete SDDM Sugar Candy theme with all components
- **Stow structure**: Properly organized for stow deployment

## Usage

### Installing the Theme

To install the SDDM Sugar Candy theme using stow:

```bash
# Navigate to your stow directory
cd ~/stow

# Install the theme
stow sddm-sugar-candy
```

This will create symbolic links from your stow directory to the system directories, making the theme available to SDDM.

### Uninstalling the Theme

To remove the theme:

```bash
# Navigate to your stow directory
cd ~/stow

# Uninstall the theme
stow -D sddm-sugar-candy
```

### Updating SDDM Configuration

After installing the theme, you need to configure SDDM to use it. Edit `/etc/sddm.conf` and add:

```ini
[Theme]
Current=sugar-candy
```

Or if the file doesn't exist, create it with:

```ini
[Theme]
Current=sugar-candy
```

### Testing the Theme

You can test the theme without logging out by running:

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/sugar-candy
```

## Customization

The theme can be customized by editing the configuration files:

- **Main config**: `/usr/share/sddm/themes/sugar-candy/theme.conf`
- **User overrides**: `/usr/share/sddm/themes/sugar-candy/theme.conf.user`

The `theme.conf.user` file is recommended for customizations as it won't be overwritten during updates.

## Requirements

- SDDM >= 0.18
- Qt5 >= 5.11
- GNU Stow

## Notes

- This stow directory is designed to work with your existing stow setup
- The theme files are organized to match the expected SDDM theme structure
- All binary assets (images, SVGs) are included in their respective directories

