# APIs, Endpoints e Serviços

## Status: Não aplicável (APIs de aplicação)

Este repositório não expõe nem implementa nenhuma API HTTP/gRPC/GraphQL. Não há
controllers, rotas, handlers, endpoints ou contratos de API no código.

| Item | Situação |
|---|---|
| Endpoints HTTP | **Não aplicável** |
| Contratos / schemas de API (OpenAPI, proto) | **Não aplicável** |
| Camada de serviços de aplicação | **Não aplicável** |
| Versionamento de API | **Não aplicável** |

## "Serviços" no sentido de systemd / NixOS

O que existe são **serviços de sistema (systemd)** habilitados declarativamente. Nenhum
deles abre portas de rede voltadas para fora por configuração explícita — o firewall do
NixOS não é configurado neste repositório (bloco `networking.firewall` está todo
comentado em `configuration.nix`, portanto o firewall assume o comportamento padrão do
NixOS: habilitado, sem portas abertas).

| Serviço | Definido em | Função |
|---|---|---|
| `systemd-boot` | `configuration.nix` | Bootloader |
| `NetworkManager` | `configuration.nix` (`networking.networkmanager.enable`) | Gestão de rede |
| `GDM` (`services.displayManager.gdm`) | `configuration.nix` | Display manager / login gráfico |
| GNOME (`services.desktopManager.gnome`) | `configuration.nix` | Ambiente de desktop |
| `xserver` (`services.xserver.enable`) | `configuration.nix` | Servidor X11 / suporte |
| CUPS (`services.printing`) | `configuration.nix` | Impressão |
| PipeWire (`services.pipewire`, + `alsa`, `pulse`) | `configuration.nix` | Áudio |
| `rtkit` (`security.rtkit`) | `configuration.nix` | Prioridade de tempo real para áudio |
| `blueman` (`services.blueman`) | `modules/hardware.nix` | Applet/serviço Bluetooth |
| Bluetooth (`hardware.bluetooth`) | `modules/hardware.nix` | Stack Bluetooth (BlueZ) |
| Flatpak (`services.flatpak`) | `modules/hardware.nix` | Runtime Flatpak |
| OpenRGB (`services.hardware.openrgb`) | `modules/hardware.nix` | Controle de iluminação RGB (porta local do daemon OpenRGB — padrão 6742, não configurada explicitamente) |
| Docker (`virtualisation.docker`) | `modules/docker.nix` | Daemon de containers (socket local) |

### Portas de rede

- Nenhum `networking.firewall.allowedTCPPorts` / `allowedUDPPorts` é definido.
- `services.openssh` está **comentado** (SSH não habilitado).
- **Não identificado:** portas efetivamente abertas em runtime (dependem de defaults dos
  serviços e não podem ser determinadas só pelo código deste repo).

## Endpoints externos consumidos

Ver `integrations.md`. Em resumo, apenas os endpoints de **build** do Nix:
`github:NixOS/nixpkgs`, `github:nix-community/home-manager` e os caches binários padrão
do Nix (`cache.nixos.org`) — nenhum endpoint de API de aplicação.
