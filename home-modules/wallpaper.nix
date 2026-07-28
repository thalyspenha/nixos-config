# home-modules/wallpaper.nix
{ config, ... }:
let
  wallpaperPath = "${config.home.homeDirectory}/Pictures/wallpapers/wallpaper.png";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ wallpaperPath ];
      wallpaper = [ "DP-1,${wallpaperPath}" ];
    };
  };
}
