# home-modules/rofi.nix
{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    theme = "gruvbox-dark";
    font = "FiraCode Nerd Font 12";
  };
}
