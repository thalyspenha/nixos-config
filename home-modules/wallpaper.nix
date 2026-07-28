# home-modules/wallpaper.nix
{ config, pkgs, ... }:
let
  wallpaperPath = "${config.home.homeDirectory}/Pictures/wallpapers/wallpaper.png";
  monitorTarget = "DP-1";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ wallpaperPath ];
      wallpaper = [ "${monitorTarget},${wallpaperPath}" ];
    };
  };

  # hyprpaper as vezes sobe antes do output do Hyprland terminar o roundtrip
  # Wayland de setup ("Found 1 output(s)" seguido de "has no target: no wp
  # will be created" no log) — a diretiva `wallpaper=` do config falha nesse
  # boot mas o mesmo comando reaplicado via IPC segundos depois funciona na
  # hora. Reaplica via IPC até o wallpaper realmente ficar ativo.
  systemd.user.services.hyprpaper.Service.ExecStartPost = [
    "${pkgs.writeShellScript "hyprpaper-apply-wallpaper" ''
      for _ in $(seq 1 20); do
        if ${pkgs.hyprland}/bin/hyprctl hyprpaper listactive 2>/dev/null | grep -q "^${monitorTarget}:"; then
          exit 0
        fi
        ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper "${monitorTarget},${wallpaperPath}" >/dev/null 2>&1
        sleep 0.3
      done
    ''}"
  ];
}
