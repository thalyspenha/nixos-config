# Infraestrutura

## Alvo

Um **único host físico** x86_64:

- Hostname: `nixos`
- CPU: AMD (`boot.kernelModules = [ "kvm-amd" ]`, `hardware.cpu.amd.updateMicrocode`,
  `services.hardware.openrgb.motherboard = "amd"`)
- Armazenamento: NVMe/SATA (`boot.initrd.availableKernelModules` inclui `nvme`, `ahci`,
  `sd_mod`, `usb_storage`)
- Filesystems: raiz `ext4`, `/boot` `vfat` (ESP), swap em partição dedicada
- Boot: UEFI + `systemd-boot`
- Placa de vídeo: aceleração via Mesa/`libva` (`modules/graphics.nix`);
  `enable32Bit = true`. **Não identificado** o fabricante da GPU pelo código (sem
  `hardware.nvidia`, sem `hardware.amdgpu` explícito; apenas `mesa` genérico).

## Docker

- `modules/docker.nix`: `virtualisation.docker.enable = true`; `thalys` no grupo `docker`.
- **Não há Dockerfile, docker-compose, nem imagens definidas** neste repositório. O Docker
  é apenas habilitado como daemon local para uso ad-hoc.
- `lazydocker` (TUI) instalado em `modules/terminal.nix`; alias `dc = "docker compose"`
  (`home.nix`).
- Rootless não configurado — o daemon roda como root e o grupo `docker` concede acesso
  equivalente a root.

## Kubernetes

- Ferramentas cliente instaladas (`kubectl`, `k9s`, `gke-gcloud-auth-plugin`) —
  ver `integrations.md`.
- **Nenhum cluster, manifesto, Helm chart ou kubeconfig** é definido/versionado aqui.

## Virtualização

- `boot.kernelModules = [ "kvm-amd" ]` habilita KVM. Nenhum `virtualisation.libvirtd`,
  `virtualisation.virtualbox` ou VM guest configurado.

## Rede

- `NetworkManager` gerencia as interfaces.
- Firewall: bloco `networking.firewall` inteiramente comentado → **default do NixOS**
  (firewall ativo, nenhuma porta liberada explicitamente).
- SSH: `services.openssh` comentado (**desabilitado**).
- Sem proxy configurado (blocos `networking.proxy.*` comentados).
- Wireless: `networking.wireless` comentado (Wi-Fi, se houver, via NetworkManager).

## Hardware periférico

- Bluetooth: `hardware.bluetooth.enable` + `services.blueman.enable` (`modules/hardware.nix`)
- RGB: `services.hardware.openrgb` com `openrgb-with-all-plugins`; requer
  `hardware.i2c.enable` e módulos `i2c-dev`, `i2c-piix4`; usuário no grupo `i2c`
- Impressão: CUPS (`services.printing.enable`)
- Áudio: PipeWire (ALSA + Pulse + 32-bit), `rtkit`

## `nix-ld`

`modules/nix-ld.nix` provê um loader dinâmico (`ld.so`) com um conjunto de bibliotecas
(`stdenv.cc.cc`, `zlib`, `openssl`, `icu`, `libunwind`) para rodar binários pré-compilados
não-Nix (comum com extensões de IDE, servidores de linguagem, ferramentas .NET/Python
baixadas dinamicamente). A mensagem de commit `84a12a0` ("adicionado fuse lib") sugere
histórico de ajustes aqui — mas o estado **atual** do arquivo não inclui `fuse`
(ver verificação cruzada em `decisions.md`).

## Fluxos operacionais (casos de uso principais)

| Fluxo | Comando | Fonte |
|---|---|---|
| Aplicar a configuração ao sistema | `sudo nixos-rebuild switch --flake /etc/nixos#nixos` | `README.md` |
| Avaliar sem aplicar ("teste") | `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run` | `docs/superpowers/plans/2026-07-29-kde-revert.md`; verificado 2026-09-10 (exit 0) |
| Atualizar dependências | `nix flake update` | `README.md` |
| Rollback | Selecionar geração anterior no menu do `systemd-boot`, ou `nixos-rebuild switch --rollback` | Comportamento padrão do NixOS (não documentado no repo) |

O repositório precisa estar em `/etc/nixos` no host (o `--flake /etc/nixos#nixos` do
README assume esse caminho). O caminho de desenvolvimento é
`/home/thalys/Projects/Pessoal/nixos-config` (working copy atual).

## Filas / Background workers

**Não aplicável.** Não há brokers de mensageria, workers, cron jobs (`services.cron` /
`systemd.timers` customizados) ou jobs agendados definidos no repositório. Os únicos
processos em background são os serviços de sistema listados acima (daemons systemd
padrão do NixOS).

## Autenticação / Autorização

- **Login local:** SDDM (gráfico) + PAM padrão do NixOS. Senha do usuário definida
  manualmente (`passwd`), não versionada.
- **Autorização local:** modelo de grupos Unix — ver `business-rules.md`
  (`wheel` → sudo; `docker` → socket Docker; `i2c`, `adbusers`).
- **`polkit`:** habilitado implicitamente pelo Plasma/serviços; nenhuma regra polkit
  customizada no repo.
- **Secret Service / keyring:** KWallet (`kwallet`) vem com o Plasma (não configurado
  explicitamente no repo atual).
- **SSH / acesso remoto de rede:** desabilitado (`services.openssh` comentado).
- Não há autenticação de aplicação (OAuth, JWT, sessões) — **Não aplicável**.

## IaC / Provisionamento de nuvem

**Não aplicável** — nenhum Terraform, Pulumi, CloudFormation, Ansible ou similar.

## CI/CD

**Ausente** — sem `.github/workflows`, `.gitlab-ci.yml`, Hydra ou qualquer pipeline.
Ver `testing.md`.
