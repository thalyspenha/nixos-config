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
    i2c-tools
    aria2

    # Utilidades
    tree
    eza
    bat
    ripgrep
    fd
    fzf
    fastfetch
    lazydocker
    openvpn

    # Editor
    vim

     # Desenvolvimento
    uv
    python315
    (google-cloud-sdk.withExtraComponents [
    google-cloud-sdk.components.gke-gcloud-auth-plugin
  ])
    k9s
    kubectl
    android-tools

    pciutils
    mesa-demos
    libva-utils
    pkgs.unrar
  ];

  programs.zsh.enable = true;
}
