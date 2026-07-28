# Migração de KDE Plasma 6 para Hyprland

**Status:** Aprovado, aguardando plano de implementação
**Data:** 2026-07-28

## Contexto

O sistema roda NixOS com KDE Plasma 6 (`services.desktopManager.plasma6.enable`) e
SDDM como display manager, em hardware AMD (CPU e GPU, sem NVIDIA), bootloader
`systemd-boot`, monitor único `DP-1` 1920x1080@120Hz.

Decisão: substituir o KDE Plasma inteiramente por Hyprland, com um rice visual
completo baseado em referência no `JaKooLit/Hyprland-Dots`, portado de forma
100% declarativa para este repositório Nix (`configuration.nix` + módulos +
`home.nix` via home-manager), em vez de rodar os scripts de instalação
upstream diretamente.

Não há avaliação de manter KDE e Hyprland coexistindo — o KDE sai por completo,
para evitar manter dois sistemas de tema em paralelo.

## Decisões confirmadas

| Decisão | Escolha |
|---|---|
| Display manager | SDDM (mantido), com tema visual novo |
| Paleta de cores | Gruvbox |
| Fidelidade ao rice de referência | Réplica funcional completa do JaKooLit (waybar, keybinds, animações, lock/idle, notificações, scripts auxiliares) |
| Wallpaper | Placeholder configurável — usuário fornece a imagem depois |
| Keybinds | Esquema padrão do JaKooLit, sem customização adicional |
| Gerenciador de arquivos | Nautilus |

## Arquitetura

Reorganização de arquivos:

- **`modules/desktop.nix`** (editado) — remove `kdePackages.kate` e
  `kdePackages.krdc`; adiciona pacotes do ecossistema Hyprland/GTK: rofi,
  swaync, grim, slurp, nautilus, ferramentas de screenshot/clipboard.
- **`configuration.nix`** (editado) — remove
  `services.desktopManager.plasma6.enable`; mantém `services.xserver.enable`
  (base pra XWayland) e `services.displayManager.sddm.enable` (tema trocado);
  adiciona `programs.hyprland.enable` e `services.displayManager.defaultSession
  = "hyprland"`.
- **`modules/hyprland.nix`** (novo) — configuração de sistema que não pertence
  ao home-manager: portals XDG (`xdg.portal`, `xdg-desktop-portal-hyprland`,
  `xdg-desktop-portal-gtk`), agente polkit gráfico.
- **`modules/sddm-theme.nix`** (novo) — empacotamento do tema SDDM com paleta
  Gruvbox.
- **`home.nix`** (editado) — blocos `wayland.windowManager.hyprland`,
  `programs.waybar`, `programs.rofi`, `programs.hyprlock`,
  `services.hypridle`, `services.swaync`, tema GTK/Qt/cursor.

## Componentes

### Hyprland (compositor)

- Monitor: `DP-1, 1920x1080@120, 0x0, 1`.
- Keybinds padrão JaKooLit: `SUPER+Q` terminal (ghostty, já configurado),
  `SUPER+E` Nautilus, `SUPER+R` rofi, `SUPER+C` fecha janela, `SUPER+1-0`
  troca workspace, `SUPER+SHIFT+1-0` move janela, `SUPER+F` fullscreen,
  `SUPER+V` floating, `SUPER+L` lock, resize/move com `SUPER+mouse`.
- Animações: bezier curves e transições (slide+fade em janelas, slide em
  workspaces) equivalentes às do JaKooLit.
- `general`: gaps, bordas e cores usando paleta Gruvbox
  (`col.active_border` em laranja/verde Gruvbox).
- `env`: `NIXOS_OZONE_WL=1` (Chrome/VS Code nativos em Wayland), mantém
  `GTK_IM_MODULE=simple` (já existente, corrige acentuação).
- `exec-once`: waybar, swaync, hyprpaper, polkit agent.

### Waybar

Módulos: workspaces, título da janela ativa, relógio, tray (bluetooth via
blueman, rede via NetworkManager), volume (pulseaudio), CPU/RAM. Estilo CSS
Gruvbox (fundo `#282828`, destaques `#fe8019`/`#b8bb26`), cantos
arredondados, módulos "pill-style" como no JaKooLit. Módulo de bateria
omitido ou condicional (é desktop).

### Rofi

Launcher de aplicativos (`SUPER+R`), tema Gruvbox, também usado para menu de
power/logout.

### Lock, idle, notificações

- `programs.hyprlock`: lock screen com blur do wallpaper, relógio, campo de
  senha estilizado Gruvbox.
- `services.hypridle`: dim de tela, depois `hyprlock`, depois suspend
  (valores padrão do JaKooLit, ajustáveis).
- `services.swaync`: central de notificações estilo painel, tema Gruvbox,
  ícone na waybar.

### SDDM

- Mantém `services.displayManager.sddm.enable = true`.
- `services.displayManager.sddm.wayland.enable = true`.
- Tema novo: `sddm-astronaut-theme` com paleta sobrescrita para Gruvbox,
  empacotado em `modules/sddm-theme.nix`. **Risco conhecido:** temas de SDDM
  fora do nixpkgs geralmente exigem empacotamento manual
  (`stdenv.mkDerivation` puxando do GitHub) — se isso se mostrar
  desproporcional durante a implementação, o fallback é usar o tema Breeze
  padrão do SDDM com paleta Gruvbox básica via `sddm.settings`, sem trocar de
  tema completo.

### Theming geral e integração

- GTK: tema Gruvbox (via home-manager `gtk.theme`), ícones (ex: Papirus
  variante escura).
- Qt: `qt.platformTheme = "gtk"` para apps Qt remanescentes seguirem o mesmo
  tema.
- Cursor: tema consistente (ex: Bibata-Modern-Classic) via `gtk.cursorTheme`
  e env do Hyprland.
- Fontes: reaproveita `modules/fonts.nix` já existente, confirmando
  cobertura de ícones Nerd Font para waybar/rofi.
- Portals XDG: necessários para screen sharing e file picker nativo em apps
  sandboxed — não vêm de graça sem o Plasma.
- Polkit agent gráfico: necessário para prompts de permissão em GUI (ex:
  montar disco, instalar via GUI) — o KDE fornecia isso, precisa de
  substituto explícito subindo via `exec-once`.
- Nautilus: adicionado em `modules/desktop.nix`.

## O que sai

- `services.desktopManager.plasma6.enable`.
- `kdePackages.kate`, `kdePackages.krdc` — removidos. Kate é substituído pelo
  VS Code, já configurado no repo; Krdc não tem substituto neste escopo (pode
  ser adicionado depois, avulso, se surgir necessidade de acesso remoto).
- `services.xserver.enable` permanece (base XWayland), `xkb`/`console.keyMap`/
  `GTK_IM_MODULE` não mudam (independentes do DE).

## Teste e rollback

- `systemd-boot` mantém gerações anteriores — se o Hyprland não subir,
  selecionar a geração com Plasma na tela de boot, ou
  `nixos-rebuild switch --rollback`.
- Não rodar `nix-collect-garbage` até confirmar a sessão Hyprland 100%
  funcional.
- Checklist de validação pós-rebuild: waybar sobe, `SUPER+Q` abre ghostty,
  `SUPER+R` abre rofi, áudio funciona, wifi/bluetooth aparecem na tray,
  hyprlock/hypridle disparam corretamente, notificação de teste aparece no
  swaync, screen sharing funciona em pelo menos um app (ex: navegador).

## Fora de escopo

- Escolha/curadoria final do wallpaper (usuário fornece depois).
- Customização de keybinds além do padrão JaKooLit.
- Portar o stack ags/quickshell do `end-4/dots-hyprland` (avaliado e
  descartado por complexidade de manutenção declarativa).
- Multi-monitor (setup atual é monitor único).
