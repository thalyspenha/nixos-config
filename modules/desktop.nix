{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    vscode

    # API Client
    bruno

    #multimedia
    vlc
    pavucontrol

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

    # Hyprland desktop
    nautilus
    grim
    slurp
    wl-clipboard
    networkmanagerapplet
    hyprpolkitagent
  ];
}
