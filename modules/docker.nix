{ ... }:

{
  virtualisation.docker.enable = true;

  users.users.thalys.extraGroups = [
    "docker"
  ];
}
