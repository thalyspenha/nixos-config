# Regras de Negócio

## Status: Não aplicável no sentido de domínio de aplicação

Não há domínio de negócio, casos de uso de usuário final, validações de entrada ou
workflows de aplicação. O que segue são as **regras/decisões de configuração** que o
repositório impõe ao sistema — o análogo mais próximo de "regras" aqui.

## Regras de configuração impostas pelo código

### Identidade e acesso local

- Existe **um único usuário normal**: `thalys` (`isNormalUser`).
- `thalys` pertence aos grupos: `networkmanager`, `wheel`, `adbusers`
  (`configuration.nix`), `docker` (`modules/docker.nix`), `i2c` (`modules/hardware.nix`).
  - `wheel` → pode usar `sudo`.
  - `docker` → acesso ao socket do Docker sem `sudo` (equivalente a root — ver
    `infrastructure.md`).
  - `adbusers` → acesso a dispositivos Android via ADB.
  - `i2c` → acesso a barramentos I²C (necessário para OpenRGB).
- Nenhuma senha é definida no código (feito manualmente via `passwd`, conforme comentário
  em `configuration.nix`).

### Shell

- Shell de login de `thalys` é `zsh` (`configuration.nix`) e `programs.zsh.enable` é
  ativado tanto no sistema (`modules/terminal.nix`) quanto no Home Manager (`home.nix`).

### Localização

- Fuso: `America/Sao_Paulo`.
- Locale padrão: `pt_BR.UTF-8`, com todas as `LC_*` sobrescritas para `pt_BR.UTF-8`.
- Layout de teclado: X11 `us` variante `intl` (US internacional com dead keys);
  console `us-acentos`.
- Comentário no código indica correção histórica de dead keys em apps GTK4 no Wayland
  (o `environment.sessionVariables.GTK_IM_MODULE = "simple"` foi **removido** na árvore
  de trabalho atual — ver `git diff`).

### Pacotes não livres

- `nixpkgs.config.allowUnfree = true` — permite instalar software proprietário
  (`google-chrome`, `android-studio`, `google-cloud-sdk`, `vscode`, etc.).

### Nix

- `nix.settings.experimental-features = [ "nix-command" "flakes" ]` — flakes obrigatório
  para este repo funcionar.

### Home Manager

- `useGlobalPkgs` + `useUserPackages`: pacotes do usuário resolvidos com o mesmo nixpkgs
  do sistema e instalados no perfil do usuário.
- `backupFileExtension = "hm-backup"`: em conflito com dotfile existente, o Home Manager
  faz backup em vez de abortar.

### Áudio

- PulseAudio **desabilitado** explicitamente; PipeWire é o servidor de áudio, com
  emulação ALSA (inclusive 32-bit) e PulseAudio.

## Casos de uso principais

Ver `infrastructure.md` → seção "Fluxos operacionais" (aplicar config, atualizar inputs,
avaliar sem aplicar). Não há casos de uso de aplicação.
