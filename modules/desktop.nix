{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    vscode
    kdePackages.kate
    pkgs.android-studio

    # API Client
    bruno

    # Acesso remoto
    kdePackages.krdc

    #multimedia
    vlc
    pkgs.picard
    pkgs.chromaprint

    #browsers
    google-chrome

    #dev
    dbeaver-bin

    #hardware
    openrgb-with-all-plugins

    #terminal
    ghostty

  ];
}
