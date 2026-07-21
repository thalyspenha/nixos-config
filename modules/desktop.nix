{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    vscode
    kdePackages.kate

    # Terminal
    ghostty

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

    openvpn

  ];
}
