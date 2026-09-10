# Módulos

> Baseado no estado atual do código. Cada arquivo `.nix` em `modules/` é um módulo NixOS
> importado por `configuration.nix`. `home.nix` é o módulo Home Manager do usuário.

## Mapa de importação

- `flake.nix` → `configuration.nix` + `home-manager.nixosModules.home-manager`
- `configuration.nix` → `hardware-configuration.nix`, `modules/terminal.nix`,
  `modules/fonts.nix`, `modules/docker.nix`, `modules/nix-ld.nix`, `modules/desktop.nix`,
  `modules/media.nix`, `modules/graphics.nix`, `modules/hardware.nix`
- `configuration.nix` → `home-manager.users.thalys = import ./home.nix`
- `home.nix` → `imports = [ ]` (vazio)

---

## `flake.nix`

- `description = "NixOS - Thalys"`
- **inputs:**
  - `nixpkgs` → `github:NixOS/nixpkgs/nixos-26.05`
  - `home-manager` → `github:nix-community/home-manager/release-26.05`, com
    `inputs.nixpkgs.follows = "nixpkgs"`
- **outputs:** `nixosConfigurations.nixos` (sistema `x86_64-linux`), módulos
  `./configuration.nix` e `home-manager.nixosModules.home-manager`.

---

## `configuration.nix` (agregador de sistema)

Principais definições:

| Área | Configuração |
|---|---|
| Boot | `systemd-boot`, EFI `canTouchEfiVariables`, kernel `linuxPackages_latest` |
| Rede | `networking.hostName = "nixos"`, `networking.networkmanager.enable = true` |
| Locale/hora | `time.timeZone = "America/Sao_Paulo"`, `i18n.defaultLocale = "pt_BR.UTF-8"` + `extraLocaleSettings` completos em pt_BR |
| Teclado | X11: `layout = "us"`, `variant = "intl"`; console: `keyMap = "us-acentos"` |
| Display | `services.xserver.enable`, `services.displayManager.gdm.enable`, `services.desktopManager.gnome.enable` |
| Impressão | `services.printing.enable = true` (CUPS) |
| Áudio | `services.pulseaudio.enable = false`; `security.rtkit.enable = true`; `services.pipewire` com `alsa`, `alsa.support32Bit`, `pulse` |
| Usuário | `users.users.thalys`: `isNormalUser`, `extraGroups = [ "networkmanager" "wheel" "adbusers" ]`, `shell = pkgs.zsh` |
| Firefox | `programs.firefox.enable = true` |
| Nix | `nixpkgs.config.allowUnfree = true`; `nix.settings.experimental-features = [ "nix-command" "flakes" ]` |
| Home Manager | `useGlobalPkgs = true`, `useUserPackages = true`, `backupFileExtension = "hm-backup"`, `users.thalys = import ./home.nix` |
| Estado | `system.stateVersion = "26.05"` |

Observação: `config` e `lib` estão na assinatura da função mas `config`/`lib` não são
usados diretamente no corpo (o `lib` foi adicionado na alteração não commitada atual).

---

## `hardware-configuration.nix` (gerado — "Do not modify this file!")

- `imports = [ (modulesPath + "/installer/scan/not-detected.nix") ]`
- `boot.initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ]`
- `boot.kernelModules = [ "kvm-amd" ]`
- `fileSystems."/"` → `ext4`, `by-uuid/7e05fa29-3060-4623-8712-e726e34f2cbb`
- `fileSystems."/boot"` → `vfat`, `by-uuid/ABD2-AE58`, `options = [ "fmask=0077" "dmask=0077" ]`
- `swapDevices` → `by-uuid/048d5ad6-0baa-43c5-b0de-c8b9f1c778d9`
- `nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux"`
- `hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware`

(As UUIDs foram alteradas na árvore de trabalho atual — ver `git diff`; indica
reinstalação ou troca de disco. Alteração ainda não commitada.)

---

## `modules/terminal.nix`

- `environment.systemPackages`: `git`, `curl`, `wget`, `jq`, `zip`, `unzip`,
  `wl-clipboard`, `i2c-tools`, `tree`, `eza`, `bat`, `ripgrep`, `fd`, `fzf`,
  `fastfetch`, `lazydocker`, `openvpn`, `vim`, `uv`,
  `google-cloud-sdk.withExtraComponents [ gke-gcloud-auth-plugin ]`, `k9s`, `kubectl`,
  `android-tools`, `pciutils`, `mesa-demos`, `libva-utils`, `unrar`
- `programs.zsh.enable = true`

## `modules/fonts.nix`

- `fonts.packages`: `nerd-fonts.fira-code`, `noto-fonts`, `noto-fonts-cjk-sans`,
  `noto-fonts-color-emoji`

## `modules/docker.nix`

- `virtualisation.docker.enable = true`
- `users.users.thalys.extraGroups = [ "docker" ]`

## `modules/nix-ld.nix`

- `programs.nix-ld.enable = true`
- `programs.nix-ld.libraries`: `stdenv.cc.cc`, `zlib`, `openssl`, `icu`, `libunwind`
- Propósito: permitir a execução de binários dinâmicos não empacotados pelo Nix
  (ex.: ferramentas baixadas por IDEs, SDKs).

## `modules/desktop.nix`

- `environment.systemPackages` (aplicativos gráficos): `gnome-text-editor`,
  `android-studio`, `bruno`, `remmina`, `vlc`, `picard`, `chromaprint`, `google-chrome`,
  `dbeaver-bin`, `openrgb-with-all-plugins`, `ghostty`, `ente-auth`, `proton-vpn`,
  `gnome-tweaks`
- Comentários de categoria no arquivo: Editor / API Client / Acesso remoto / multimedia /
  browsers / dev / hardware / terminal / auth / vpn / tweak
- `ente-auth`, `proton-vpn`, `gnome-tweaks` foram adicionados na árvore de trabalho atual
  (não commitado); `vscode` foi removido daqui (é gerido pelo Home Manager — ver `home.nix`).

## `modules/media.nix`

- `environment.systemPackages`: `ffmpeg`, `libdvdcss`

## `modules/graphics.nix`

- `hardware.graphics.enable = true`
- `hardware.graphics.enable32Bit = true`
- `hardware.graphics.extraPackages`: `mesa`, `libva`, `libva-utils`

## `modules/hardware.nix`

- `users.users.thalys.extraGroups = [ "i2c" ]`
- `boot.kernelModules = [ "i2c-dev" "i2c-piix4" ]`
- `hardware.bluetooth.enable = true`; `services.blueman.enable = true`
- `services.flatpak.enable = true`
- `hardware.i2c.enable = true`
- `services.hardware.openrgb`: `enable = true`, `package = pkgs.openrgb-with-all-plugins`,
  `motherboard = "amd"`

---

## `home.nix` (Home Manager — usuário `thalys`)

- `home.username = "thalys"`, `home.homeDirectory = "/home/thalys"`,
  `home.stateVersion = "26.05"`
- `home.sessionPath = [ "$HOME/.local/bin" ]`
- `imports = [ ]` — nenhum submódulo
- `programs.home-manager.enable = true`
- `programs.direnv`: `enable = true`, `nix-direnv.enable = true`
- `programs.zsh`: `enable`, `autosuggestion.enable`, `syntaxHighlighting.enable`,
  `shellAliases` = `{ ls = "eza --icons"; ll = "eza -lah --icons --git"; cat = "bat";
  grep = "rg"; ff = "fastfetch"; dc = "docker compose"; }`
- `programs.starship`: `enable`, `settings` (add_newline, símbolos de `character`,
  `directory.style`, `git_branch.symbol = "🌱 "`)
- `programs.vscode`: `enable`, `profiles.default`:
  - **extensions:** `ms-dotnettools.csharp`, `ms-dotnettools.vscode-dotnet-runtime`,
    `ms-python.python`, `ms-azuretools.vscode-docker`, `ms-dotnettools.csdevkit`,
    `usernamehw.errorlens`, `esbenp.prettier-vscode`, `pkief.material-icon-theme`,
    `sdras.night-owl`
  - **userSettings:** fonte `FiraCode Nerd Font Mono` + ligatures, `formatOnSave`,
    minimap desativado, terminal padrão `zsh`, `workbench.iconTheme = "material-icon-theme"`,
    `workbench.colorTheme = "Night Owl"`, `editor.codeActionsOnSave."source.fixAll" = "always"`

> Nota: `workbench.iconTheme` foi ajustado de `"vscode-icons"` para `"material-icon-theme"`
> em 2026-09-10, para corresponder à extensão instalada `pkief.material-icon-theme`
> (ver `decisions.md` I2).

## Módulos historicamente existentes (removidos — não estão no código atual)

Do `git log`: `modules/hyprland.nix`, `modules/sddm-theme.nix`, `modules/bruno.nix`,
`modules/vscode.nix`, `home-modules/*` (hyprland, waybar, rofi, lock-idle, notifications,
wallpaper, theme), `gruvbox-palette.nix`. Listados apenas para contexto histórico.
