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
    hyprpicker
    hyprlock
    hypridle
    hyprpaper
    hyprshot
    hyprkeys # ersetzt hyprbind (nicht in nixpkgs verfügbar)
    mako
    cliphist
    wl-clipboard
    playerctl
    brightnessctl
    btop
    fish
    chromium
    polkit_gnome
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

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    # settings/bind-Listen sind für configType="lua" nicht zuverlässig unterstützt
    # (nix-community/home-manager#9468, "not planned") -> komplette Config als
    # rohes Lua über Hyprlands eigene Lua-API (hl.*), analog zu
    # https://github.com/mpetutschnig/arch_hyperland_tui/blob/main/dot_config/hypr/{var,binds}.conf
    extraConfig = ''
      local mainMod = "SUPER"
      local terminal = "foot"

      -----------------------------
      -- Environment
      -----------------------------
      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_SIZE", "24")
      hl.env("QT_QPA_PLATFORM", "wayland;xcb")
      hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
      hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
      hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
      hl.env("QT_STYLE_OVERRIDE", "kvantum")
      hl.env("GDK_BACKEND", "wayland,x11,*")
      hl.env("SDL_VIDEODRIVER", "wayland")
      hl.env("CLUTTER_BACKEND", "wayland")
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_TYPE", "wayland")
      hl.env("XDG_SESSION_DESKTOP", "Hyprland")

      -----------------------------
      -- Autostart
      -----------------------------
      hl.on("hyprland.start", function()
        hl.exec_cmd("waybar")
        hl.exec_cmd("hyprpaper") -- Hinweis: hyprpaper.conf/Wallpaper wurde nicht übernommen (Pfad im Referenz-Repo existiert nicht)
        hl.exec_cmd("vicinae server")
        hl.exec_cmd("hypridle")
        hl.exec_cmd("mako")
        hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
        hl.exec_cmd("wl-paste --type text --watch cliphist store")
        hl.exec_cmd("wl-paste --type image --watch cliphist store")
      end)

      -----------------------------
      -- Keybinds: Basis
      -----------------------------
      hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(terminal .. " -e yazi"))
      hl.bind(mainMod .. " + O",      hl.dsp.exec_cmd("obsidian"))
      hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
      hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd("uwsm stop")) -- statt "exit": sauberes Beenden unter UWSM
      hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("vicinae toggle"))
      hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd("vicinae toggle"))
      hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd("chromium"))
      hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd("hyprlock --grace 5"))
      hl.bind(mainMod .. " + P",      hl.dsp.exec_cmd("hyprpicker | wl-copy"))
      hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
      hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd(terminal .. " -e hyprkeys")) -- ersetzt hyprbind, ggf. Flags anpassen
      hl.bind("ALT + TAB", hl.dsp.cyclenext())
      hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(terminal .. " --app-id tuibtop fish -c btop"))

      -- Fensterzustände (best effort - Lua-API dafür ist kaum dokumentiert)
      hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = 1 })) -- maximize
      hl.bind(mainMod .. " + CTRL + F",  hl.dsp.window.fullscreen({ mode = 0 })) -- echter Fullscreen
      hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

      -----------------------------
      -- Workspaces
      -----------------------------
      for i = 1, 9 do
        hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
      end
      hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
      hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))
      hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special())
      hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))

      -- Workspace-Scroll (best effort)
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

      -----------------------------
      -- Maus
      -----------------------------
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -----------------------------
      -- Medientasten / Hardware
      -----------------------------
      hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
      hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("brightnessctl s +5%"),  { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
      hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),  { locked = true })

      -----------------------------
      -- Screenshots
      -----------------------------
      hl.bind(mainMod .. " + PRINT",        hl.dsp.exec_cmd("hyprshot -m output"))
      hl.bind(mainMod .. " + CTRL + P",     hl.dsp.exec_cmd("hyprshot -s -z -m region"))
      hl.bind("PRINT",                      hl.dsp.exec_cmd("hyprshot -m region"))
    '';
  };

  home.stateVersion = "24.05";
}
