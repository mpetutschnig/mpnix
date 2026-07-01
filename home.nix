{ config, pkgs, ... }:
{
  home.username = "mp";
  home.homeDirectory = "/home/mp";
  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    includes = [ "/files/.ssh/config" ];
  };

  home.packages = with pkgs; [
    foot
    waybar
    vicinae # App-Launcher (ersetzt fuzzel)
    wofi # nur für die Clipboard-Historie (cliphist)
    yazi
    obsidian
    swaylock # Lockscreen (ersetzt hyprlock, Hyprland-spezifisch)
    swayidle # Idle-Daemon (ersetzt hypridle)
    swaybg # Wallpaper (ersetzt hyprpaper, Hyprland-spezifisch)
    grim
    slurp
    imagemagick # für den Color-Picker (grim+slurp+convert), ersetzt hyprpicker
    mako
    cliphist
    wl-clipboard
    playerctl
    brightnessctl
    btop
    fish
    chromium
  ];

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

  # niri wird über niri.nixosModules.niri (modules/desktop.nix) installiert;
  # das home-manager-Modul (programs.niri.settings) wird dadurch automatisch
  # importiert. Typisiertes Nix statt rohem KDL/Lua - wird beim Build validiert.
  #
  # Hinweise zu Abweichungen von deinem Hyprland-Referenz-Repo
  # (https://github.com/mpetutschnig/arch_hyperland_tui):
  # - niris Tiling ist scrollbares Spalten-Layout, kein dwindle/floating-Mix;
  #   Maus-Move/Resize-Binds (mouse:272/273) entfallen daher (Spalten werden
  #   per move-column-*/consume/expel neu angeordnet, floating Fenster per CSD gezogen).
  # - Alt+Tab ist bereits ein niri-Bordmittel (recent-windows), kein eigener Bind nötig.
  # - togglespecialworkspace (Mod+S) hat keine 1:1-Entsprechung in niri, weggelassen.
  # - niris eigenes "Overview"-Feature (Mod+O) wurde zugunsten von Obsidian (dein Mod+O) geopfert.
  programs.niri.settings = {
    environment = {
      XCURSOR_SIZE = "24";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_STYLE_OVERRIDE = "kvantum";
      GDK_BACKEND = "wayland,x11,*";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      NIXOS_OZONE_WL = "1"; # Electron-Apps (vscode etc.) auf Wayland
    };

    spawn-at-startup = [
      { argv = [ "waybar" ]; }
      { argv = [ "mako" ]; }
      { argv = [ "vicinae" "server" ]; }
      { argv = [ "swaybg" "--mode" "fill" "--color" "#1e1e2e" ]; } # kein Bild hinterlegt, siehe Hinweis unten
      { sh = "wl-paste --type text --watch cliphist store"; }
      { sh = "wl-paste --type image --watch cliphist store"; }
      { sh = "swayidle -w timeout 300 'swaylock -f' before-sleep 'swaylock -f'"; }
    ];

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

      # --- Programme ---
      "Mod+Return".action.spawn = "foot";
      "Mod+T".action.spawn = "foot";
      "Mod+E".action.spawn = [ "foot" "-e" "yazi" ];
      "Mod+O".action.spawn = "obsidian";
      "Mod+D".action.spawn = [ "vicinae" "toggle" ];
      "Mod+Space".action.spawn = [ "vicinae" "toggle" ];
      "Mod+W".action.spawn = "chromium";
      "Mod+L".action.spawn = "swaylock";
      "Mod+V".action.spawn-sh = "cliphist list | wofi --dmenu | cliphist decode | wl-copy";
      "Mod+P".action.spawn-sh =
        ''grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -n1 | grep -oP '#[0-9A-Fa-f]{6}' | wl-copy'';
      "Ctrl+Shift+Escape".action.spawn = [ "foot" "--app-id" "tuibtop" "fish" "-c" "btop" ];

      # --- Fenster schließen / beenden ---
      "Mod+Q".action.close-window = [ ];
      "Mod+Shift+E".action.quit = [ ];

      # --- Fokus zwischen Fenstern/Spalten ---
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      # kein Mod+L für focus-column-right: L ist per Referenz-Repo an swaylock gebunden,
      # Mod+Right deckt dieselbe Aktion ab

      # --- Fenster/Spalten verschieben ---
      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];

      # --- Spalte einsammeln/auswerfen ---
      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

      # --- Fensterzustände ---
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+M".action.maximize-window-to-edges = [ ];
      "Mod+Shift+V".action.toggle-window-floating = [ ];

      # --- Workspaces (1-9, Fenster statt ganzer Spalte verschieben) ---
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
      "Mod+Shift+5".action.move-window-to-workspace = 5;
      "Mod+Shift+6".action.move-window-to-workspace = 6;
      "Mod+Shift+7".action.move-window-to-workspace = 7;
      "Mod+Shift+8".action.move-window-to-workspace = 8;
      "Mod+Shift+9".action.move-window-to-workspace = 9;

      "Mod+WheelScrollDown".cooldown-ms = 150;
      "Mod+WheelScrollDown".action.focus-workspace-down = [ ];
      "Mod+WheelScrollUp".cooldown-ms = 150;
      "Mod+WheelScrollUp".action.focus-workspace-up = [ ];

      # --- Medientasten / Hardware (allow-when-locked wie zuvor bindel/bindl) ---
      "XF86AudioRaiseVolume".allow-when-locked = true;
      "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+" ];
      "XF86AudioLowerVolume".allow-when-locked = true;
      "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
      "XF86AudioMute".allow-when-locked = true;
      "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
      "XF86AudioMicMute".allow-when-locked = true;
      "XF86AudioMicMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
      "XF86MonBrightnessUp".allow-when-locked = true;
      "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "set" "+5%" ];
      "XF86MonBrightnessDown".allow-when-locked = true;
      "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "set" "5%-" ];
      "XF86AudioNext".allow-when-locked = true;
      "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
      "XF86AudioPause".allow-when-locked = true;
      "XF86AudioPause".action.spawn = [ "playerctl" "play-pause" ];
      "XF86AudioPlay".allow-when-locked = true;
      "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
      "XF86AudioPrev".allow-when-locked = true;
      "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];

      # --- Screenshots (niri-Bordmittel statt hyprshot) ---
      "Mod+Print".action.screenshot-screen = [ ];
      "Mod+Ctrl+P".action.screenshot = [ ];
      "Print".action.screenshot = [ ];
    };
  };

  home.stateVersion = "24.05";
}
