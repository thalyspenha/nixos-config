{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ffmpeg
    libdvdcss
  ];

  nixpkgs.config.allowUnfree = true;
}
