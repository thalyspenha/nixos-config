# Arquitetura

> Documentação baseada no estado atual do código (branch `main`, commit `0dc301b`).
> Análise feita em 2026-09-10.

## Natureza do projeto

Este repositório **não é uma aplicação de software**. É a **configuração declarativa de
um único host NixOS pessoal** (hostname `nixos`, usuário `thalys`), versionada como um
Nix Flake. Não há código de aplicação, servidor, banco de dados ou API.

Por consequência, várias seções do roteiro de análise solicitado não se aplicam e estão
marcadas como tal nos documentos correspondentes (`database.md`, `api.md`,
`business-rules.md` — parcialmente, etc.).

## Visão geral

```
flake.nix  (ponto de entrada — define inputs e a saída nixosConfigurations.nixos)
   │
   ├── inputs:
   │     ├── nixpkgs        → github:NixOS/nixpkgs/nixos-26.05
   │     └── home-manager   → github:nix-community/home-manager/release-26.05
   │                          (inputs.nixpkgs.follows = "nixpkgs")
   │
   └── nixosConfigurations.nixos = nixpkgs.lib.nixosSystem
         system = "x86_64-linux"
         modules = [
           ./configuration.nix
           home-manager.nixosModules.home-manager
         ]
```

`configuration.nix` é o agregador do lado do sistema. Ele importa:

```
configuration.nix
 ├── hardware-configuration.nix      (gerado por nixos-generate-config; disco, kernel modules, CPU)
 ├── modules/terminal.nix            (ferramentas CLI + programs.zsh)
 ├── modules/fonts.nix               (fontes do sistema)
 ├── modules/docker.nix              (virtualisation.docker + grupo docker)
 ├── modules/nix-ld.nix              (nix-ld para binários dinâmicos não-Nix)
 ├── modules/desktop.nix             (aplicativos gráficos via environment.systemPackages)
 ├── modules/media.nix               (ffmpeg, libdvdcss)
 ├── modules/graphics.nix            (hardware.graphics / aceleração)
 └── modules/hardware.nix            (bluetooth, i2c, OpenRGB, flatpak)
```

E, via `home-manager.nixosModules.home-manager`, integra o Home Manager como módulo NixOS:

```
configuration.nix
 └── home-manager.users.thalys = import ./home.nix
       home.nix
        └── imports = [ ]   (nenhum submódulo home-manager atualmente)
       configura: zsh, starship, direnv, vscode
```

## Camadas

| Camada | Arquivo(s) | Responsabilidade |
|---|---|---|
| Flake / entrada | `flake.nix`, `flake.lock` | Pinagem de dependências, definição da saída `nixosConfigurations.nixos` |
| Sistema (NixOS) | `configuration.nix` + `modules/*.nix` + `hardware-configuration.nix` | Boot, kernel, rede, locale, serviços, desktop, pacotes de sistema, usuário |
| Usuário (Home Manager) | `home.nix` | Dotfiles e programas do usuário `thalys` (shell, prompt, editor) |
| Hardware (gerado) | `hardware-configuration.nix` | Filesystems, swap, módulos de kernel de armazenamento, microcode AMD |

Não há separação em múltiplos hosts nem em perfis (`nixosConfigurations` tem uma única
entrada, `nixos`).

## Modelo de execução

- **Build/aplicação:** `sudo nixos-rebuild switch --flake /etc/nixos#nixos`
  (conforme `README.md`). O flake espera estar em `/etc/nixos` no host.
- **Avaliação sem aplicar (equivalente a "rodar os testes"):**
  `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run`
  (documentado em `docs/superpowers/plans/2026-07-29-kde-revert.md`). Verificado em
  2026-09-10: avalia com sucesso (exit 0).
- **Atualização de dependências:** `nix flake update` (regenera `flake.lock`).

## Bootloader e kernel

- `boot.loader.systemd-boot.enable = true`
- `boot.loader.efi.canTouchEfiVariables = true`
- `boot.kernelPackages = pkgs.linuxPackages_latest` (kernel mais recente do nixpkgs)
- `hardware-configuration.nix`: `boot.kernelModules = [ "kvm-amd" ]` (CPU AMD),
  microcode AMD via `hardware.cpu.amd.updateMicrocode`.

## Estado / persistência

- `system.stateVersion = "26.05"` (`configuration.nix`)
- `home.stateVersion = "26.05"` (`home.nix`)
- `home-manager.backupFileExtension = "hm-backup"` — dotfiles pré-existentes conflitantes
  são renomeados para `*.hm-backup` em vez de causar falha.

## Histórico arquitetural relevante

O `git log` mostra várias trocas de ambiente gráfico (ver `decisions.md`):
KDE Plasma → Hyprland (jul/2026) → revert para KDE Plasma → **GNOME** (commit `0dc301b`,
estado atual). Os documentos em `docs/superpowers/` descrevem o ciclo Hyprland→KDE e
estão **desatualizados** em relação ao estado atual (GNOME) — ver `testing.md` /
verificação cruzada em `decisions.md`.

## Itens não identificados / não aplicáveis

- Arquitetura de aplicação (camadas de domínio, serviços, controllers): **Não aplicável.**
- Múltiplos "projetos" / monorepo: **Não aplicável** — repositório de config única.
- Diagramas C4 / componentes de runtime de aplicação: **Não aplicável.**
