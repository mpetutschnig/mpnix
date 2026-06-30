{ pkgs, inputs, ... }:

{
  # 1. Hyprland mit UWSM aktivieren
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  # 2. Display Manager (SDDM mit Wayland-Support)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # Optional: Ein schönes Theme (muss ggf. vorher installiert werden)
    # theme = "catppuccin-mocha"; 
  };

  # 3. Security & Polkit (notwendig für Root-Rechte in Apps)
  security.polkit.enable = true;

  # 4. XDG Desktop Portal (für Dateidialoge/Screensharing)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # 5. Hardware-Beschleunigung (für Video/Browser/Tuxedo)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
