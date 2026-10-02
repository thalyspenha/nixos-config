# Dependências

## Dependências do flake (build-time)

Definidas em `flake.nix`, pinadas em `flake.lock` (versão 7):

| Nome | URL | Ref | Rev | Notas |
|---|---|---|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs` | `nixos-26.05` | `6aefcda9401be8acc2b74244fb3b37520ea1f0a8` | Único canal; sem `unstable` |
| `home-manager` | `github:nix-community/home-manager` | `release-26.05` | `fd0956c99c41ae3c13a73a638f1f7e963aebc4ab` | `inputs.nixpkgs.follows = "nixpkgs"` (não traz nixpkgs próprio) |

`flake.lock` na árvore de trabalho está **atualizado** em relação ao `flake.nix`
(`nix flake update` foi executado — ver `git diff`, alteração não commitada).

Sistema alvo: `x86_64-linux` (`flake.nix` e `hardware-configuration.nix`).
Toolchain Nix local no host: Nix 2.34.8, NixOS `26.05.20260909` (verificado 2026-09-10).

## Pacotes de sistema (`environment.systemPackages` / `fonts.packages` / `programs.*`)

Todos vêm de `nixpkgs`. `nixpkgs.config.allowUnfree = true` permite pacotes proprietários.

### CLI — `modules/terminal.nix`
`git`, `curl`, `wget`, `jq`, `zip`, `unzip`, `wl-clipboard`, `i2c-tools`, `tree`, `eza`,
`bat`, `ripgrep`, `fd`, `fzf`, `fastfetch`, `lazydocker`, `openvpn`, `vim`, `uv`,
`google-cloud-sdk` (+ componente `gke-gcloud-auth-plugin`), `k9s`, `kubectl`,
`android-tools`, `pciutils`, `mesa-demos`, `libva-utils`, `unrar`

### GUI — `modules/desktop.nix`
`kdePackages.kate`, `android-studio`, `bruno`, `kdePackages.krdc`, `vlc`, `picard`, `chromaprint`,
`google-chrome`, `dbeaver-bin`, `openrgb-with-all-plugins`, `ghostty`, `ente-auth`,
`proton-vpn`
*(`vscode` foi removido
daqui — passou a ser gerido pelo Home Manager)*

### Mídia — `modules/media.nix`
`ffmpeg`, `libdvdcss`

### Gráficos — `modules/graphics.nix`
`hardware.graphics.extraPackages`: `mesa`, `libva`, `libva-utils`

### Fontes — `modules/fonts.nix`
`nerd-fonts.fira-code`, `noto-fonts`, `noto-fonts-cjk-sans`, `noto-fonts-color-emoji`

### `nix-ld` libs — `modules/nix-ld.nix`
`stdenv.cc.cc`, `zlib`, `openssl`, `icu`, `libunwind`

### Programas habilitados como módulos
- Sistema: `programs.firefox`, `programs.zsh`, `programs.nix-ld`
- Serviços que trazem pacotes: `services.pipewire`, `services.printing` (CUPS),
  `services.flatpak`, `services.hardware.openrgb`, `services.blueman`,
  `services.displayManager.sddm`, `services.desktopManager.plasma6`,
  `virtualisation.docker`

## Dependências do usuário (Home Manager — `home.nix`)

Programas geridos: `home-manager`, `direnv` (+ `nix-direnv`), `zsh` (+ `autosuggestion`,
`syntaxHighlighting`), `starship`, `vscode`.

### Extensões do VS Code (`programs.vscode.profiles.default.extensions`)
De `pkgs.vscode-extensions`: `ms-dotnettools.csharp`,
`ms-dotnettools.vscode-dotnet-runtime`, `ms-python.python`, `ms-azuretools.vscode-docker`,
`ms-dotnettools.csdevkit`, `usernamehw.errorlens`, `esbenp.prettier-vscode`,
`pkief.material-icon-theme`, `sdras.night-owl`

## Gestão de linguagens/projetos

- `direnv` + `nix-direnv` (`home.nix`) — ambientes de desenvolvimento por diretório
  (`.envrc` / `devShell`), embora **nenhum `flake.nix`/`shell.nix` de projeto exista
  neste repo).
- `uv` — gestor de pacotes/venv Python (uso ad-hoc do usuário).

## Não identificado / ausente

- Lockfiles de linguagem (package.json, Cargo.toml, go.mod, etc.): **ausentes** — não há
  projeto de software aqui.
- Overlays de nixpkgs, pacotes de terceiros fora de nixpkgs, `nixpkgs-unstable`:
  **ausentes**.
