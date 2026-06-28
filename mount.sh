#!/usr/bin/env bash
# mount_and_install.sh Anwendung: Führe dieses Skript aus, wenn du im Live-Medium bist.
set -e # Beenden bei Fehler
# 1. Mounts vorbereiten
sudo umount -R /mnt || true sudo mount -o subvol=@,compress=zstd,noatime /dev/sda2 /mnt sudo mkdir -p 
/mnt/{boot,nix,persist,files}
# 2. Subvolumes und Boot
sudo mount /dev/sda1 /mnt/boot sudo mount -o subvol=@nix,compress=zstd,noatime /dev/sda2 /mnt/nix sudo 
mount -o subvol=@persist,compress=zstd,noatime /dev/sda2 /mnt/persist
# 3. Daten-Partition einhängen
sudo mount /dev/sdb1 /mnt/files
# 4. Installation starten (Pfad zu deiner Flake anpassen!)
cd /mnt/files/git/mpnix sudo nixos-install --flake .#laptop echo "Installation abgeschlossen! Bitte 
Root-Passwort setzen und rebooten."
