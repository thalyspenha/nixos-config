{ pkgs, ... }:

{
  users.users.thalys.extraGroups = [ "i2c" ];

  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.flatpak.enable = true;

  #openrgb
  hardware.i2c.enable = true;
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
  };
}
