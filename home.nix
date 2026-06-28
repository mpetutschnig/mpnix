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

  programs.vscode = {
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

  home.stateVersion = "24.05";
}
