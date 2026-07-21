{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal
    git
    curl
    wget
    jq
    zip
    unzip
    wl-clipboard

    # Utilidades
    tree
    eza
    bat
    ripgrep
    fd
    fzf
    fastfetch

    # Editor
    vim

     # Desenvolvimento
    (dotnetCorePackages.combinePackages [
    dotnetCorePackages.sdk_8_0
    dotnetCorePackages.sdk_10_0
  ])
    uv

    pciutils
    mesa-demos
    libva-utils
  ];

  programs.zsh.enable = true;
}
