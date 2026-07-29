# Reverter Hyprland -> KDE Plasma

## Contexto

A migração para Hyprland (commits `cbdc1a6`..`b2f0d75`) foi concluída em
2026-07-28. Em 2026-07-29 o usuário decidiu abandonar o Hyprland e voltar
para o KDE Plasma, que era o ambiente anterior à migração (estado no
commit `af40e1b`). Este é um revert completo e deliberado, não um ajuste
pontual.

Investigação do histórico confirmou que todos os commits da migração
tocam exclusivamente arquivos relacionados a desktop/Hyprland — nenhuma
mudança de sistema não relacionada (docker, fonts, terminal, etc.) foi
misturada no meio. Isso permite um revert cirúrgico sem risco de perder
trabalho não relacionado.

## Escopo

### Restaurado (para o estado pré-migração)

- `configuration.nix`:
  - Remove os imports de `./modules/hyprland.nix` e
    `./modules/sddm-theme.nix`.
  - Readiciona `services.desktopManager.plasma6.enable = true;` (o
    `services.displayManager.sddm.enable = true;` já está presente e
    permanece).
- `modules/desktop.nix`:
  - Remove pacotes exclusivos do ecossistema Hyprland: `nautilus`,
    `grim`, `slurp`, `wl-clipboard`, `networkmanagerapplet`,
    `hyprpolkitagent`, `pavucontrol`.
  - Restaura `kdePackages.kate` e `kdePackages.krdc`.

### Removido (exclusivo da era Hyprland)

- `modules/hyprland.nix`
- `modules/sddm-theme.nix`
- `home-modules/hyprland.nix`
- `home-modules/waybar.nix`
- `home-modules/rofi.nix`
- `home-modules/lock-idle.nix`
- `home-modules/notifications.nix`
- `home-modules/wallpaper.nix`
- `home-modules/theme.nix`
- `gruvbox-palette.nix`
- Os 7 imports correspondentes em `home.nix`
- `docs/superpowers/plans/2026-07-28-hyprland-migration.md`
- `docs/superpowers/specs/2026-07-28-hyprland-migration-design.md`

### Inalterado

- `flake.nix` / `flake.lock` (home-manager já era usado antes da
  migração, para zsh/starship/vscode/direnv — não é exclusivo do
  Hyprland).
- `.gitignore` (as duas linhas adicionadas — `result` e `.worktrees/` —
  são genéricas, não específicas do Hyprland).
- Todos os outros módulos: `terminal.nix`, `fonts.nix`, `docker.nix`,
  `nix-ld.nix`, `media.nix`, `graphics.nix`, `hardware.nix`.
- `home.nix`: mantém tudo que não é import de módulo removido (zsh,
  starship, vscode, direnv, sessionPath).

## Fora de escopo

- O sistema de múltiplos temas (Gruvbox/Catppuccin/Tokyo
  Night/Rosé Pine) que estava sendo desenhado para o Hyprland foi
  abandonado junto — não se aplica a um ambiente KDE Plasma padrão.
  Nenhuma customização de tema do Plasma está incluída aqui; se o
  usuário quiser um tema para o KDE no futuro, é um novo ciclo de
  brainstorm.

## Validação

- `nixos-rebuild dry-build` (ou `build`) deve compilar sem erros após
  as mudanças, confirmando que a configuração é avaliável.
- Não faz parte deste plano rodar `nixos-rebuild switch` automaticamente
  — trocar de sessão gráfica em produção é uma ação com efeito
  colateral real (logout/relogin) e deve ser confirmada e executada
  pelo usuário.
