{ pkgs, ... }:

{
  # Visual estilo macOS (aplicar com scripts/aplicar-mac.sh)
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
