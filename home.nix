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

  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  programs.vscode = {
    enable = true;
    
    

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      #ms-python.python           # Für Machine Learning / Python Scripts
      #dbaeumer.vscode-eslint     # Für JavaScript/Fastify
      #fwcd.kotlin                # Für Kotlin
      
      # KI-Assistenten (je nachdem, welchen du für Claude/Gemini nutzt)
      # z.B. continue.continue oder github.copilot
    ]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # 2. Erweiterungen direkt aus dem VS Code Marketplace
      {
        name = "claude-code";
        publisher = "anthropic";
        version = "2.1.195";
        sha256 = "0000000000000000000000000000000000000000000000000000";
      }
      {
        name = "markdown-runner";
        publisher = "renathossain";
        version = "3.3.0";
        sha256 = "0000000000000000000000000000000000000000000000000000";
      }
      {
        name = "pdf";
        publisher = "tomoki1207";
        version = "1.2.2";
        sha256 = "0000000000000000000000000000000000000000000000000000";
      }
      {
        name = "vscode-httpyac";
        publisher = "anweber";
        version = "6.16.7";
        sha256 = "0000000000000000000000000000000000000000000000000000";
      }
    ];

    # 3. Deine settings.json direkt in Nix integriert
    userSettings = {
      "editor.formatOnSave" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "telemetry.telemetryLevel" = "off";
    };
  };


  # State Version (NICHT ÄNDERN!)
  system.stateVersion = "24.05";
}