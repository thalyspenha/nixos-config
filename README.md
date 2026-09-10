# NixOS Configuration

Configuração declarativa de um host NixOS pessoal (hostname `nixos`, usuário `thalys`),
como Nix Flake. Documentação completa em [`docs/`](docs/) e contexto para agentes em
[`CLAUDE.md`](CLAUDE.md).

## Aplicar alterações

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

> O comando acima assume que o conteúdo deste repositório está em `/etc/nixos` (por
> cópia ou symlink). Rodando a partir do próprio diretório do repositório, use:
>
> ```bash
> sudo nixos-rebuild switch --flake .#nixos
> ```

## Avaliar sem aplicar (verificação equivalente a "rodar os testes")

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run
```

## Atualizar os inputs

```bash
nix flake update
```

## Estrutura

- `flake.nix` / `flake.lock` → inputs (nixpkgs, home-manager) e saída `nixosConfigurations.nixos`
- `configuration.nix` → agregador do sistema (boot, rede, locale, serviços, usuário)
- `hardware-configuration.nix` → gerado por `nixos-generate-config` (disco, kernel, CPU) — **não editar manualmente**
- `home.nix` → configurações do usuário via Home Manager (zsh, starship, direnv, vscode)
- `modules/terminal.nix` → ferramentas CLI + `programs.zsh`
- `modules/desktop.nix` → aplicativos gráficos
- `modules/graphics.nix` → drivers e aceleração de vídeo
- `modules/fonts.nix` → fontes
- `modules/docker.nix` → daemon Docker + grupo `docker`
- `modules/media.nix` → codecs (ffmpeg, libdvdcss)
- `modules/hardware.nix` → bluetooth, i2c, OpenRGB, flatpak
- `modules/nix-ld.nix` → loader para binários dinâmicos não-Nix
