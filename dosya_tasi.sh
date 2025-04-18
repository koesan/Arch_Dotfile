#!/bin/bash

# Scriptin bulunduğu dizini al
script_dir="$(pwd)"

# Dotfile klasörünün yolu (script ile aynı dizinde olduğu varsayılıyor)
dotfile_dir="$script_dir/dotfile"

# Home dizini
home_dir="$HOME"

# .config dizini
config_dir="$HOME/.config"

# .config dizinine taşınacak klasörler
config_folders=("alacritty" "waybar" "wlogout" "wofi" "hypr")

# Home dizinine taşınacak dosyalar ve klasörler
home_files=(".icons" ".themes" ".zshrc")

# .config dizinine taşınacak klasörleri taşı
for folder in "${config_folders[@]}"; do
  # Eğer hedef dizinde aynı isimde bir klasör varsa, sil
  if [ -d "$config_dir/$folder" ]; then
    echo "$folder dizini .config içinde var, siliniyor..."
    rm -rf "$config_dir/$folder"
  fi
  # Klasörü taşımaya başla
  if [ -d "$dotfile_dir/$folder" ]; then
    echo "$folder dizini .config içine taşınıyor..."
    mv "$dotfile_dir/$folder" "$config_dir"
  fi
done

# Home dizinine taşınacak dosyaları ve klasörleri taşı
for file in "${home_files[@]}"; do
  # Eğer hedef dizinde aynı isimde bir dosya veya klasör varsa, sil
  if [ -e "$home_dir/$file" ]; then
    echo "$file dosyası home dizininde var, siliniyor..."
    rm -rf "$home_dir/$file"
  fi
  # Dosyayı taşımaya başla
  if [ -e "$dotfile_dir/$file" ]; then
    echo "$file dosyası home dizinine taşınıyor..."
    mv "$dotfile_dir/$file" "$home_dir"
  fi
done

echo "İşlem tamamlandı!"
