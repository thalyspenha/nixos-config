# modules/hyprland.nix
{ ... }:

{
  programs.hyprland.enable = true;

  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm.wayland.enable = true;

  # hyprlock (diferente do swaylock, já coberto por programs.hyprland.enable)
  # precisa do próprio serviço PAM pra aceitar senha — sem isso o unlock
  # nunca autentica. Ver modules/lock-idle.nix no home-manager.
  security.pam.services.hyprlock = { };

  # KDE trazia o KWallet como Secret Service, auto-desbloqueado pelo PAM do
  # SDDM junto com o Plasma. Sem substituto, apps libsecret (ex: ente-auth)
  # falham com "Failed to unlock the keyring". gnome-keyring assume esse
  # papel; o hook de PAM no sddm é o que desbloqueia com a senha de login.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
