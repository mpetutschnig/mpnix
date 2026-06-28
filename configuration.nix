{ config, pkgs, inputs, ... }:

{
  # System-Locale auf Österreich Zwingt NixOS, das klassische Bash-Skript für den Rollback zu 
  # akzeptieren
  i18n.defaultLocale = "de_AT.UTF-8"; boot.initrd.systemd.enable = false;
  
  boot.loader.systemd-boot.enable = true; boot.loader.efi.canTouchEfiVariables = true;

  console.keyMap = "de"; 

  boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
    mkdir -p /mnt
    mount -o subvol=/ /dev/sdb2 /mnt
    
    echo "Lösche altes Root-Subvolume..."
    btrfs subvolume delete /mnt/@ || true
    
    echo "Stelle leeren Snapshot wieder her..."
    btrfs subvolume snapshot /mnt/@-blank /mnt/@
    
    umount /mnt
  '';

  # --- SOPS Secrets ---
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  # Der Pfad, wo der Age-Key auf dem fertigen System liegen wird (überlebt den Rollback)
  sops.age.keyFile = "/persist/keys.txt"; 

  sops.secrets.mp_password = {
    neededForUsers = true;
  };

  # --- User 'mp' ---
  users.users.mp = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    hashedPasswordFile = config.sops.secrets.mp_password.path;
  };
  # Erlaube proprietäre Software (wie VS Code)
  nixpkgs.config.allowUnfree = true;

  # --- Basis-Pakete & Container ---
  environment.systemPackages = with pkgs; [
    git
    nano
    curl
    wget
    distrobox # Für saubere Entwicklungs-Spaces
  ];

  # Podman für rootless Container (ersetzt Docker)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # --- Modernes Audio & Netzwerk ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

services.openssh = {
  enable = true;
  settings.PasswordAuthentication = true;
};
networking.firewall.allowedTCPPorts = [ 22 ];

# 1. Secret bekannt machen
sops.secrets.wifi_pw_home = {}; 

# 2. In die Profile einbinden
networking.networkmanager.ensureProfiles.profiles = {
  "wifi-msml-5g" = {
    connection = {
      id = "wifi-msml-5g";
      type = "wifi";
    };
    wifi = {
      ssid = "wifi-msml-5g";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      # Hier greifen wir direkt auf das entschlüsselte Secret zu
      psk = config.sops.placeholder.wifi_pw_home;
    };
  };
};



  networking.hostName = "mpnix";
  networking.networkmanager.enable = true;

  # State Version (NICHT ÄNDERN!)
  system.stateVersion = "24.05";
}
