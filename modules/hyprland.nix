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
}
