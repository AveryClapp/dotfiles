# Clone official themes
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes

# Create or update your alacritty.toml
cat >>~/.config/alacritty/alacritty.toml <<'EOF'

[general]
import = [
    "~/.config/alacritty/themes/themes/alabaster.toml"
]
EOF
