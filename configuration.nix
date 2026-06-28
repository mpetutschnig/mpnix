{ config, pkgs, inputs, ... }:

{
  # --- Bootloader ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # --- Erase-Your-Darling (Btrfs Rollback Script) ---
  # Setzt das Root-Subvolume (@) bei jedem Boot auf den leeren Snapshot (@-blank) zurück.
  boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
    mkdir -p /mnt
    # Mountet die Btrfs-Partition (wird bei der Installation /dev/sdb2 sein)
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

  # --- WLAN Secret laden ---
  sops.secrets.wireless_env = {};

  # --- Deklaratives WLAN Profil ---
  networking.networkmanager.ensureProfiles.environmentFiles = [
    config.sops.secrets.wireless_env.path
  ];
  networking.networkmanager.ensureProfiles.profiles = {
    "wifi-msml-5g" = {
      connection = {
        id = "wifi-msml-5g";
        type = "wifi";
      };
      wifi = {
        ssid = "wifi-msml-5g";
      };
      "wifi-security" = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PW_HOME";
      };
    };

    "wifi-msml" = {
      connection = {
        id = "wifi-msml-5g";
        type = "wifi";
      };
      wifi = {
        ssid = "wifi-msml-5g";
      };
      "wifi-security" = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PW_HOME";
      };
    };

    
  };



  networking.hostName = "mpnix";
  networking.networkmanager.enable = true;

  # State Version (NICHT ÄNDERN!)
  system.stateVersion = "24.05";
}