{ pkgs, ... }:

{
  # Temas estilo macOS (aplicados manualmente pelas Configurações do Sistema)
  environment.systemPackages = with pkgs; [
    #temas
    whitesur-kde
    whitesur-gtk-theme
    kdePackages.qtstyleplugin-kvantum

    #icones e cursor
    whitesur-icon-theme
    whitesur-cursors
  ];
}
