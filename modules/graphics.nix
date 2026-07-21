{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;

    enable32Bit = true;

    extraPackages = with pkgs; [
      mesa
      libva
      libva-utils
      mesa.drivers
    ];
  };
}
