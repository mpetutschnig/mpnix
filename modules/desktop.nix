{ pkgs, ... }:

{
  # 1. niri aktivieren
  # niri.nixosModules.niri kümmert sich dabei selbst um xdg-desktop-portal-gnome,
  # Polkit-Agent und GNOME-Keyring - kein manuelles xdg.portal/security.polkit nötig.
  programs.niri.enable = true;

  # 2. Display Manager (SDDM mit Wayland-Support)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # Optional: Ein schönes Theme (muss ggf. vorher installiert werden)
    # theme = "catppuccin-mocha";
  };

  # Tastaturlayout für SDDM-Greeter, Wayland-Sessions & (via console.useXkbConfig) die TTY
  services.xserver.xkb.layout = "at"; # "at" = Österreich (XKB-Ländercode, nicht "de-AT")

  # 3. Hardware-Beschleunigung (für Video/Browser/Tuxedo)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
