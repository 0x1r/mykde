#Script 1
echo "Welcome to Arch Linux Magic Script"
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
echo "Enter the drive: "
read drive
cfdisk $drive 
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition 
read -p "Did you also created efi partition? [yn]" answer

if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi

mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware intel-ucode git vim
genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' arch_install.sh > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
#i915 nvidia(mkinitcpio -p linux)
pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
sed -i -e 's/MODULES=(.*)/MODULES(i915 nvidia)/' /etc/mkinitcpio.conf
mkinitcpio -p linux
passwd
# echo root:password | chpasswd
# pacman --noconfirm -S grub efibootmgr os-prober
pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call  virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font

echo "Enter EFI partition: " 
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# pacman --noconfirm -S dhcpcd networkmanager 
# systemctl enable NetworkManager.service 
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
# systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

rm /arch_install2.sh

#visudo
#EDITOR=vim visudo
#uncomment wheel

#echo "Enter Username: "
#read username
#useradd -m -G wheel -s /bin/bash $username
#passwd $username

#swapfile
dd if=/dev/zero of=/swapfile bs=1M count=8024 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
# vim /etc/fstab
#(swapfile as comment)
echo "/swapfile  none   swap   defaults   0 0" >> /etc/fstab
echo "Pre-Installation Finish Reboot now"
