{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    gnome-text-editor
    pkgs.android-studio

    # API Client
    bruno

    # Acesso remoto
    remmina

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

    #auth
    ente-auth

    #vpn
    proton-vpn

    #tweak
    gnome-tweaks

  ];
}
