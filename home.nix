{ config, pkgs, ... }:
{
  home.username = "mp";
  home.homeDirectory = "/home/mp";
  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    includes = [ "/files/.ssh/config" ];
  };

  home.packages = with pkgs; [ foot waybar fuzzel ];

  programs.vscode.profiles.default = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
#      {
#        name = "claude-code";
#        publisher = "anthropic";
#        version = "0.1.0";
#        sha256 = "0000000000000000000000000000000000000000000000000000";
#      }
#      {
#        name = "markdown-runner";
#        publisher = "renathossain";
#        version = "0.0.1";
#        sha256 = "0000000000000000000000000000000000000000000000000000";
#      }
      {
        name = "pdf";
        publisher = "tomoki1207";
        version = "1.2.2";
        sha256 = "sha256-i3Rlizbw4RtPkiEsodRJEB3AUzoqI95ohyqZ0ksROps=";
      }
      {
        name = "vscode-httpyac";
        publisher = "anweber";
        version = "6.13.0";
        sha256 = "sha256-/VYCN8aAeSsrTx9gcyW3cQ4bqtwOv5DAJmbyv8RwPnQ=";
      }
    ];
  };

wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER"; # Windows-Taste als Modifikator

      # Beispiel Keybinds
bind = [
      "$mod, RETURN, exec, alacritty"
      "$mod, E,      exec, alacritty -e hx"                # Helix direkt öffnen
      "$mod, D,      exec, wofi --show drun"               # App-Launcher
      "$mod, Q,      killactive,"
      "$mod, M,      exit,"
      "$mod, F,      togglefloating,"
      "$mod, P,      pseudo, # dwindle"
      "$mod, J,      togglesplit, # dwindle"
    ];

    # --- Workspace Navigation ---
    # Binds für 1-9
    binde = [
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, SHIFT, 1, movetoworkspace, 1"
      "$mod, SHIFT, 2, movetoworkspace, 2"
    ];

    # --- System & Hardware (Tuxedo/Audio) ---
    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86MonBrightnessUp,  exec, brightnessctl s +5%"
      ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
    ];

    # --- Maus-Binds ---
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
    };
  };

  home.stateVersion = "24.05";
}
