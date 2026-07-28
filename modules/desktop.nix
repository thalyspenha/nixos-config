{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    vscode
    kdePackages.kate

    # API Client
    bruno

    # Acesso remoto
    kdePackages.krdc

    #multimedia
    vlc

    #torrent
    qbittorrent

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
