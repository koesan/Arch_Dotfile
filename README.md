# Arch Linux Kurulum Rehberi

| ![20250418_04h29m34s_grim](resimler/20250418_04h29m34s_grim.png) | ![20250418_04h29m47s_grim](resimler/20250418_04h29m47s_grim.png) |
| ---------------------------------------------------------------- | ---------------------------------------------------------------- |
| ![20250418_04h30m10s_grim](resimler/20250418_04h30m10s_grim.png) | ![20250418_04h32m49s_grim](resimler/20250418_04h32m49s_grim.png) |

Bu rehberde, **Arch Linux** kurulumu ve yapılandırması için adımlar sırasıyla verilmiştir. Ayrıca bazı popüler uygulamaların kurulumları da yer almaktadır.

Bu kurulum **Arch Linux**'a özgüdür ve kullandığım Arch dağıtımı **EndeavourOS**'tur. EndeavourOS kurulumu hakkında internette birçok kaynak bulunmaktadır. Ancak, bu kurulum **diğer Arch tabanlı dağıtımlarda** da uygulanabilir. **Fedora**, **Debian** veya diğer dağıtımlarda bu kurulum test edilmemiştir, bu yüzden bu tür sistemlerde çalışıp çalışmayacağı garanti edilemez. Bu tür dağıtımlarda çalışmak için bazı ayarlamalar ve farklı paket yönetimi komutları gerekebilir.

**Uyarı**: Arch ve Arch tabanlı dağıtımlar, genellikle ileri düzey kullanıcılar için tasarlanmıştır. Yani bu kurulum sırasında karşılaşılan sorunlar, çözülmesi biraz daha fazla bilgi ve deneyim gerektirebilir. Başlamadan önce, sisteminizin yedeğini almanızı ve yeterli teknik bilgiye sahip olduğunuzdan emin olmanızı öneririm.

## Çekirdek ve Masaüstü Ortamı

Daha önceki Arch dağıtımlarında yaşadığım sorunlar ve deneyimlerim nedeniyle, sistemimde **2. bir çekirdek** ve **2. bir masaüstü ortamı** bulunduruyorum. Genel olarak **Zen çekirdeği** ve **GNOME masaüstü ortamı** tercih ediyorum. Ancak, farklı çekirdekler ve masaüstü ortamları kullanmanız da mümkündür. Kendi kullanım ihtiyaçlarınıza göre **Linux çekirdekleri** ve **masaüstü ortamları** arasında değişiklik yaparak, sisteminizi daha verimli hale getirebilirsiniz.

Bu, tamamen kişisel tercihlere ve kullanım senaryolarına bağlıdır, ve sisteminizin farklı konfigürasyonlarla nasıl çalıştığını test etmek de faydalı olabilir.

## Notlar:

> [!NOTE] **Config dosyaları için uyarı:**  
> Eğer config dosyalarınızda `.txt` uzantısı varsa, **.txt** ibaresini kaldırın. Dosya ismi yalnızca **config** olmalıdır.

> [!TIP] **Hazır Script Kullanımına Dair Uyarı:**  
> Bu repoda **hazır bir kurulum scripti** sunmamamın nedeni, internet üzerinde çok sayıda hazır dotfile kurulum scripti bulunduğundan dolayı bunların çoğu genel bir kurulum sağlar. Ancak bu tür scriptler, istediğiniz özelleştirmeleri yapmanıza genellikle olanak tanımaz ve bazen istemediğiniz ya da gereksiz gördüğünüz uygulamalar da kurulabilir.  
> 
> Bu yüzden adım adım kurulumu tercih ettim. Bu yöntemle, her aşamada istediğiniz kurulumu yapabilir, örneğin: **wofi yerine rofi** kullanabilir, **kendi terminal emilatörünüzü** veya **dosya yöneticinizi** seçebilirsiniz. Bu sayede daha özelleştirilmiş bir ortam elde edersiniz.

---

# KURULUM

## 0. Dosyaları Taşı

**dosya_tasi.sh** script'ini kullanarak dosyaları otomatik olarak taşıyabilirsiniz. Eğer bu script'i kullanmak istemiyorsanız, **dotfile** klasörü içerisindeki **alacritty**, **waybar**, **wlogout**, **wofi**, **hypr** klasörlerini **.config** klasörü içerisine taşıyın ve **.icons**, **.themes**, **.zshrc** dosya ve klasörlerini ise **home** dizinine taşıyın.

Aşağıdaki komutları kullanarak dosyalarınızı otomatik olarak taşıyabilirsiniz:

```bash
chmod +x dosya_tasi.sh
./dosya_tasi.sh
```

---

## 1. Sistemi Güncelle

Öncelikle, sisteminizi güncelleyerek en son paketleri almanız önemlidir.

```bash
sudo pacman -Syu
```

---

## 2. Timeshift Kurulumu

Sistem yedeği almak için Timeshift uygulamasını kurun.

```bash
sudo pacman -S timeshift
```

---

## 3. Yay (AUR Yardımcısı) Kurulumu

AUR'dan (Arch User Repository) paketleri yüklemek için yay (yay) aracını kurmanız gerekir.

Gerekli araçları yükleyin:

```bash
sudo pacman -S git base-devel
```

Yay’ı klonlayın ve kurun:

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay/
```

---

## 4. Google Chrome Kurulumu

```bash
yay -S google-chrome
```

---

## 5. Sublime Text Kurulumu

Sublime Text, popüler bir metin editörüdür. Kurulum için aşağıdaki kurulum yollarından birini çalıştırın:

### Pacman

```bash
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg

echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf

sudo pacman -Syu sublime-text
```

### Aur

```bash
yay -S sublime-text-4
```

---

### 5.1 Key Bindings (Klavye Kısayolları)

1. Sublime Text’te **Preferences → Key Bindings** menüsünü açın.  
2. Sağ taraftaki kullanıcı dosyasına aşağıdaki JSON’u ekleyin (veya var olan benzer satırları güncelleyin):

```json
[
    { "keys": ["ctrl+down"],  "command": "move", "args": { "by": "lines", "forward": true,  "extend": true } },
    { "keys": ["ctrl+up"],    "command": "move", "args": { "by": "lines", "forward": false, "extend": true } },
    { "keys": ["ctrl+shift+b"], "command": "exec", "args": { "kill": true } }
]
```

Kaydedip kapattıktan sonra

- **Ctrl + ↓ / Ctrl + ↑** ile satır satır seçim yapabilirsiniz.  
- **Ctrl + Shift + B** ile çalışan **build** işlemini sonlandırabilirsiniz.

---

### 5.2 Tema & Renk Şeması

1. **Package Control** kurulu değilse `Tools → Install Package Control` ile yükleyin.  
2. **Ctrl + Shift + P** → `Package Control: Install Package` komutunu açın ve **Brogrammer** yazıp **Enter**’a basın.  

**Tema seçimi**

- **Preferences → Color Scheme…** menüsünden **Brogrammer**’ı,  
- **Preferences → Select Theme…** menüsünden **Adaptive**’i seçin.

Arayüzünüz artık koyu‑renkli, renkli ikonlu ve modern bir görünüme kavuşur.

---

### 5.3 Eklentiler

> **Nasıl kurulur?**  
> `Ctrl + Shift + P` → `Package Control: Install Package` → eklenti adını yazıp **Enter**.

| Eklenti Adı             | Ne İşe Yarar?                                                                                          |
| ----------------------- | ------------------------------------------------------------------------------------------------------ |
| **Markdown Preview**    | `Ctrl + B` ile aynı dizinde `.html` oluşturur; **Preview in Browser** komutuyla canlı ön‑izleme sunar. |
| **SideBarEnhancements** | Dosya & klasör sağ‑tık menüsüne ek eylemler kazandırır.                                                |
| **BracketHighlighter**  | Parantez, köşeli ve süslü parantez eşlerini vurgular.                                                  |
| **A File Icon**         | Dosya türlerine göre renkli ikonlar gösterir.                                                          |
| **AutoFileName**        | Dosya yolu/adı tamamlama sağlar.                                                                       |

---

### 5.4 Otomatik Tamamlama (Python Odaklı)

| Paket           | Açıklama                                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------ |
| **LSP**         | Dil Sunucusu Protokolü ile akıllı tamamlama, hata tespiti, sembol gezintisi sağlar.              |
| **LSP‑pyright** | Python 3 için hızlı & hafif dil sunucusu; type‑checking, refactor, oto‑import özellikleri sunar. |

1. `Ctrl + Shift + P` → **Package Control: Install Package** → **LSP**  
2. Aynı adımla **LSP-pyright** paketini yükleyin.  
3. **Preferences → Package Settings → LSP → Servers** dosyasına girerek `pyright` sunucusunun etkin olduğundan emin olun.

---

### 5.5 Kısayol: Markdown Ön‑İzleme Hızlı Kullanım

| Kısayol / Komut                   | Etki                                                                       |
| --------------------------------- | -------------------------------------------------------------------------- |
| **Ctrl + B**                      | Aktif `.md` dosyasını `.html`’e derler ve tarayıcıda açar.                 |
| **Ctrl + Shift + P → “Preview…”** | “Markdown Preview: Preview in Browser” komutuyla anlık ön‑izleme başlatır. |

Bu adımlarla Sublime Text, verimli bir Markdown ve Python geliştirme ortamına dönüşmüş olur.  
Herhangi bir ek özelleştirme ihtiyacında yine buradayım!

---

## 6. Zen Kernel Kurulumu

Çekirdekte bir sorun yaşanması durumunda alternatif bir çekirdeğe sahip olmak faydalı olabilir. Bu nedenle, Zen çekirdeğini mevcut çekirdeğin yanına kurabilirsiniz. Çekirdek seçimi, sistem başlatılırken GRUB ekranı üzerinden yapılabilir.

```bash
sudo pacman -S linux-zen linux-zen-headers
```

grub kullanıyorsanız grub dosyasını güncelle.

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 7. Hyprland Kurulumu (Wayland)

Hyprland'i ve gerekli bazı paketleri yükleyin.

```bash
sudo pacman -S hyprland hyprpaper grim slurp hyprpolkitagent xdg-desktop-portal-hyprland
```

Ekran paylaşımı için gerekli paketleri yükleyin:

```bash
sudo pacman -S pipewire wireplumber
yay -S xdg-desktop-portal-hyprland-git
```

### Ses Sorunu Çözümü - Arch Linux

1. **Ses Sistemlerini Kontrol Etme:**
   Aşağıdaki komutu çalıştırarak sisteminizde hangi ses sistemlerinin aktif olduğunu kontrol edin:
   
   ```bash
   ps -e | grep -E 'pulse|pipe'
   
     31196 ?        00:00:00 pipewire
     31335 ?        00:00:00 pulseaudio
   
   Eğer burdaki gibi PulseAudio ve PipeWire aynı anda çalışıyorsa, çakışmaya sebep olabilir.
   ```

2. Eğer çakışan iki sistem varsa, bunlardan birini kaldırın. 

        **Örneğin**, PulseAudio'yu kaldırmak için(PulseAudio GNOME masaüstü ortamında         gereklidir):

```bash
sudo pacman -Rns pulseaudio
```

3. Kaldırdığınız PulseAudio yerine PipeWire’ı yükleyin:

```bash
sudo pacman -S pipewire pipewire-audio pipewire-pulse wireplumber
```

4. PipeWire servislerini yeniden başlatın:

```bash
systemctl --user daemon-reexec
systemctl --user restart pipewire pipewire-pulse wireplumber
```

Bu Mikrafon sorununu çözmez ise internete araştırma yapman gerekecek.

Hyprland'ı varsayılan yapmak için portals.conf dosyasını oluşturuyoruz:

```bash
mkdir -p ~/.config/xdg-desktop-portal
echo -e "[preferred]\ndefault=xdg-desktop-portal-hyprland" > ~/.config/xdg-desktop-portal/portals.conf
systemctl --user restart xdg-desktop-portal
```

Hyprland NVIDIA ayarı:

GRUB ayarlarını düzenlemek için aşağıdaki komutu kullanın:

```bash
sudo nano /etc/default/grub
```

GRUB_CMDLINE_LINUX_DEFAULT kısmında, eğer aşağıdaki satır varsa:

```json
GRUB_CMDLINE_LINUX_DEFAULT='nowatchdog nvme_load=YES nvidia_drm.modeset=1 loglevel=3'
```

Bunu sonuna boşluk bırakarak ekleyin:

```json
GRUB_CMDLINE_LINUX_DEFAULT='nowatchdog nvme_load=YES nvidia_drm.modeset=1 loglevel=3 nvidia.NVreg_PreserveVideoMemoryAllocations=1'
```

Eğer herhangi bir şey yoksa, `GRUB_CMDLINE_LINUX_DEFAULT=nvidia.NVreg_PreserveVideoMemoryAllocations=1` satırını ekleyin, ardından değişiklikleri kaydedip çıkın.

Son olarak, aşağıdaki komutu çalıştır:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

thema ve icon için

```bash
cat > ~/.config/xdg-desktop-portal/hyprland-portals.conf <<'EOF'
[preferred]
default=hyprland;gtk
EOF
```

Dosyaları aktarmak için:

```bash
cp -r configs/hypr "$HOME/.config/"
```

Timeshift gibi uygulamaların düzgün çalışması için DBus çevre değişkenlerini güncelliyoruz (ilk çalıştırma yeterli):

```bash
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE &
```

Her açılışta root'a yetki verilmesi için ~/.profile dosyasına ekliyoruz:

```bash
sudo pacman -S xorg-xhost
echo "xhost +SI:localuser:root" >> ~/.profile
```

### Gereksiz XDG portal paketlerini temizlemek için:

```bash
pacman -Q | grep xdg-desktop-portal-
sudo pacman -Rns xdg-desktop-portal-wlr
```

Fazladan masaüstü portal paketlerini temizlemek isterseniz aşağıdaki adımları izleyebilirsiniz.

```bash
pacman -Q | grep xdg-desktop-portal-
```

Çıktısı: 

```bash
xdg-desktop-portal-gnome 48.0-2
xdg-desktop-portal-gtk 1.15.3-1
xdg-desktop-portal-hyprland-git 1.3.9.r4.g150b0b6-1
```

Burada, ikinci masaüstü ortamınıza ait portal paketlerine, uyumsuzluk yaşanmaması için dokunmamalısınız. xdg-desktop-portal-hyprland-git Hyprland için gereklidir, ayrıca xdg-desktop-portal-gtk bazı uygulamalar için faydalı olabilir. Bunların dışındaki portal paketleri gereksizse kaldırabilirsiniz.

Gereksiz bir portal paketini kaldırmak için

```bash
sudo pacman -Rns xdg-desktop-portal-wlr
```

Bu kadar! Bu adımlarla Hyprland'ı varsayılan yapmış ve xhost yetkisini kalıcı hale getirmiş olduk. Sistemini yeniden başlattığında her şey çalışıyor olmalı.

---

## 8. Waybar Kurulumu

Waybar, Wayland tabanlı bir durum çubuğudur. Gerekli paketleri kurmak için.

```bash
sudo pacman -S waybar otf-font-awesome ttf-arimo-nerd noto-fonts xsensors pulseaudio blueman networkmanager btop
```

Giriş/çıkış ekranı için wlogout'u kurun:

```bash
yay -S wlogout
```

Dosyaları aktarmak için:

```bash
cp -r configs/wlogout "$HOME/.config/"
```

Bir uygulama başlatıcı ekleyin:

```bash
sudo pacman -S wofi
```

Dosyaları aktarmak için:

```bash
cp -r configs/wofi "$HOME/.config/"
```

# veya

```bash
sudo pacman -S rofi
```

Dosyaları aktarmak için:

```bash
cp -r configs/waybar "$HOME/.config/"
```

---

## 9. Nemo Dosya Yöneticisi Kurulumu

Nemo dosya yöneticisini yüklemek için:

```bash
sudo pacman -S nemo cinnamon-translations file-roller nemo-fileroller
```

Nemo confilerini aktarmak için:

```bash
cp -r /configs/nemo/nemo $HOME/.config/
dconf load /org/nemo/ < /configs/nemo/nemo-dconf.conf
```

---

## 10. Alacritty Terminal Kurulumu

Alacritty, hızlı bir terminal emülatörüdür.

```bash
sudo pacman -S alacritty
```

Dosyaları aktarmak için:

```bash
cp -r configs/alacritty "$HOME/.config/"
```

---

## 11. Zsh Kurulumu ve Yapılandırması

Zsh terminali, zengin özelliklere sahip bir kabuktur.

```bash
sudo pacman -S zsh
```

```bash
chsh -s $(which zsh)
```

Sistemi yeniden başlatın ve değişikliği kontrol etmek için.

```bash
sudo reboot
```

```bash
echo $SHELL #bash yerine zsh çıktısı olamsı lazım bin/zsh gibi
```

Dosyaları aktarmak için:

```bash
cp -r configs/.zshrc "$HOME/"
```

### Gerekli araçlar

```bash
sudo pacman -S curl git wget
```

### Oh My Zsh ve eklenti kurulumu

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

---

## 12. Python Kurulumu

Python ve pip'yi yükleyin:

```bash
sudo pacman -S python-pip python python-virtualenv

# pip hata çözümü
python3 -m pip config set global.break-system-packages true
```

---

## 13. PYENV:

```bash
pacman -S pyenv
yay -S pyenv-virtualenvwrapper
pyenv virtualenvwrapper
```

```bash
eval "$(pyenv init -)"
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
source $HOME/.zshrc
```

---

## 14. Swap Alanı Oluşturma

8 GB'lık bir swap alanı oluşturmak için:

```bash
swapon --show
sudo swapoff -v /swapfile
sudo su
dd if=/dev/zero of=/swapfile bs=1024 count=8388608
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile     swap     swap    defaults    0 0" >> /etc/fstab
```

---

## 15. FlatPak:

```bash
sudo pacman -S flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Tema ve İcon kullanma:

```bash
# 1) Flatpak uygulamalarına tema‑ikon klasörlerini tanıt
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --filesystem=$HOME/.icons
# 2) Tüm Flatpak uygulamalarına hangi tema / ikon setini kullanacağını söyle
sudo flatpak override --env=GTK_THEME=Andromeda-gtk
sudo flatpak override --env=ICON_THEME=dracula-icons-main
```

### Bazı FlatPak uygulamalar:

#### Google

```bash
flatpak install flathub com.google.Chrome
```

#### Bottles(for exe):

```bash
flatpak install flathub com.usebottles.bottles
```

#### Pinta

```bash
flatpak install flathub com.github.PintaProject.Pinta
```

#### Mark Text

```bash
flatpak install flathub com.github.PintaProject.Pinta
```

### Kurulu FlatPak uygulamalarını listelemek ve çaşıştırmak için

kurulu flatpak uygulamalarını listele:

```bash
flatpak list
```

```json
➜  Arch_Dotfile git:(main) ✗ flatpak list
Ad                                Uygulama Kimliği                        Sürüm  Dal          Kurulum
Şişeler                           com.usebottles.bottles                  51.21  stable       system
Mesa                              org.freedesktop.Platform.GL.default     25.0.3 24.08        system
Mesa (Extra)                      org.freedesktop.Platform.GL.default     25.0.3 24.08extra   system
Mesa                              org.freedesktop.Platform.GL32.default   25.0.3 24.08        system
FFmpeg extension with extra code… org.freedesktop.Platform.ffmpeg-full           24.08        system
i386                              ….freedesktop.Platform.ffmpeg_full.i386        24.08        system
openh264                          org.freedesktop.Platform.openh264       2.5.1  2.5.1        system
GNOME Application Platform versi… org.gnome.Platform                             47           system
i386                              org.gnome.Platform.Compat.i386                 47           system
gecko                             org.winehq.Wine.gecko                          stable-24.08 system
mono                              org.winehq.Wine.mono                           stable-24.08 system
➜  Arch_Dotfile git:(main) ✗
```

Uygulama çalıştır:

```bash
flatpak run com.usebottles.bottles #("uygulama Kimliği")
```

Uygulama güncelle:

```bash
flatpak update # flatpak update com.usebottles.bottles bir uygulama güncelle 
```

---

## 16. Uygulamalar

### LİBREOFFİCE

```bash
sudo pacman -S steam
```

Microsoft office font

```bash
yay -S ttf-ms-fonts
fc-cache -fv
```

---

### STEAM

```bash
sudo pacman -S steam
```

Driver kurma ksımında sisteminizdeki ekran kartına göre bir seçim yapmanız gerekiyor. Benim sistemde nvidia olduğundan dolayı 2.seçeneği seçtim

```bash
:: lib32-vulkan-driver için 9 sağlayıcı mevcut:
:: Depo multilib
   1) lib32-amdvlk  2) lib32-nvidia-utils  3) lib32-vulkan-dzn  4) lib32-vulkan-gfxstream
   5) lib32-vulkan-intel  6) lib32-vulkan-nouveau  7) lib32-vulkan-radeon  8) lib32-vulkan-swrast
   9) lib32-vulkan-virtio

Bir sayı girin (default=1): 2
```

### code

```bash
sudo pacman -S code
```

### VLC

```bash
sudo pacman -S vlc
```

---

## 17. DOCKER

```bash
sudo pacman -S docker 
```

Başlatmak için:

```bash
sudo systemctl start docker          # Docker servisini başlat
#sudo systemctl enable docker         # Docker servisini sistem başlangıcında başlatmak için
```

Sudo kullanmamak için:

```bash
sudo usermod -aG docker $USER
```

---

## 18. Tema ve İkonlar

Görsel özelleştirme için Nwg-look aracını ve ikonları yükleyin:

```bash
sudo pacman -S nwg-look
# Temaları ve ikonları ~/.icons ve ~/.themes dizinlerine yerleştirin
```

Dosyaları aktarmak için:

```bash
cp -r configs/.themes "$HOME/"
cp -r configs/.icons  "$HOME/
```

Ardından, ***nwg-look*** programını çalıştırarak tema ve ikonları değiştirebilirsiniz.

---

## 19. Gereksiz paketleri kaldır(EndeavourOS gnome için):

```bash
sudo pacman -Rn gnome-console xterm gnome-terminal meld gnome-text-editor gnome-weather
sudo pacman -Rndd nautilus
sudo pacman -Rnc firefox firefox-i18n-tr
```

---

Bu adımları takip ederek sisteminizi işlevsel, özelleştirilmiş ve güncel bir hale getirebilirsiniz. Arch Linux'un sunduğu esneklik sayesinde, kendi ihtiyaçlarınıza en uygun yapılandırmayı oluşturabilirsiniz. Unutmayın, bu süreç bazen zorlu olabilir, ancak elde edeceğiniz sonuçlar tamamen kişisel tercihleriniz doğrultusunda özelleştirilmiş güçlü bir sistem olacaktır.

Herhangi bir sorunla karşılaşırsanız, Arch topluluğu ve ilgili kaynaklar size yardımcı olmaktan mutluluk duyacaktır. Başarılar ve keyifli bir sistem deneyimi dilerim!
