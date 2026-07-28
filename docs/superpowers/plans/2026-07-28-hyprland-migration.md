# Migração KDE Plasma → Hyprland Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir o KDE Plasma 6 por Hyprland neste NixOS, com rice completo (paleta Gruvbox) baseado em `JaKooLit/Hyprland-Dots`, 100% declarado em Nix (system modules + home-manager).

**Architecture:** `configuration.nix`/`modules/*.nix` ganham o Hyprland em nível de sistema (compositor, SDDM temático, portals — a maior parte vem de graça do módulo `programs.hyprland` do NixOS). `home.nix` importa uma nova pasta `home-modules/` com um arquivo por componente do rice (compositor, waybar, rofi, lock/idle, notificações, wallpaper, tema GTK/Qt/cursor), todos consumindo uma paleta Gruvbox compartilhada em `gruvbox-palette.nix` na raiz do repo.

**Tech Stack:** NixOS 26.05 + home-manager release-26.05 (flakes), Hyprland, waybar, rofi, hyprlock/hypridle, SwayNotificationCenter (swaync), hyprpaper, SDDM (tema `sddm-astronaut-theme`), Nautilus.

## Global Constraints

- Repo já usa `nixpkgs/nixos-26.05` + `home-manager/release-26.05` (`flake.nix`) — não trocar de canal.
- `home.stateVersion = "26.05"` já está setado em `home.nix` — **isso muda o default de `wayland.windowManager.hyprland.configType` do home-manager para `"lua"`** (novo formato de config em Lua). Este rice usa a sintaxe clássica `hyprlang` (a mesma dos dotfiles JaKooLit e de toda a documentação da comunidade), então todo `home-modules/hyprland.nix` **precisa** setar `configType = "hyprlang";` explicitamente.
- Hardware é AMD (CPU e GPU), sem NVIDIA — nenhum workaround de driver é necessário.
- Monitor único: `DP-1`, `1920x1080@120Hz` (confirmado via `xrandr`).
- Bootloader `systemd-boot` — gerações antigas ficam disponíveis no boot como rede de segurança. **Não rodar `nix-collect-garbage` até a checklist de verificação manual (Task 12) passar.**
- Comando de verificação para toda task (não precisa de sudo, não ativa nada): `nixos-rebuild build --flake .#nixos` a partir da raiz do repo.
- Spec de referência: `docs/superpowers/specs/2026-07-28-hyprland-migration-design.md`.

---

## Task 1: Paleta de cores Gruvbox compartilhada

**Files:**
- Create: `gruvbox-palette.nix`

**Interfaces:**
- Produces: um attrset plano de cores hex **sem** o prefixo `#` (ex: `bg0 = "282828"`), importável via `import ../gruvbox-palette.nix` (a partir de `home-modules/`) ou `import ../gruvbox-palette.nix` (a partir de `modules/`). Consumido pelas Tasks 4, 5, 6, 8, 9.

- [ ] **Step 1: Criar o arquivo da paleta**

```nix
# gruvbox-palette.nix
{
  bg0 = "282828";
  bg1 = "3c3836";
  bg2 = "504945";
  bg3 = "665c54";
  fg0 = "fbf1c7";
  fg1 = "ebdbb2";
  red = "fb4934";
  green = "b8bb26";
  yellow = "fabd2f";
  blue = "83a598";
  purple = "d3869b";
  aqua = "8ec07c";
  orange = "fe8019";
  gray = "928374";
}
```

- [ ] **Step 2: Verificar sintaxe**

Run: `nix-instantiate --parse gruvbox-palette.nix`
Expected: imprime o attrset sem erro.

- [ ] **Step 3: Commit**

```bash
git add gruvbox-palette.nix
git commit -m "feat: adiciona paleta de cores Gruvbox compartilhada"
```

---

## Task 2: Remover KDE Plasma e habilitar Hyprland no nível de sistema

**Files:**
- Modify: `configuration.nix`
- Create: `modules/hyprland.nix`
- Create: `modules/sddm-theme.nix` (placeholder `{ }`, substituído com conteúdo real na Task 4)

**Interfaces:**
- Consumes: nada.
- Produces: `programs.hyprland.enable = true` (isso já habilita `xdg.portal` com `xdg-desktop-portal-hyprland` e `xdg-desktop-portal-gtk`, `security.polkit.enable`, `security.pam.services.swaylock`, `programs.dconf.enable`, e `services.xserver.desktopManager.runXdgAutostartIfNone = true` automaticamente — confirmado lendo `nixos/modules/programs/wayland/hyprland.nix` e `wayland-session.nix` do nixpkgs pinado). `security.pam.services.hyprlock` (necessário à parte — hyprlock não é o swaylock, tem seu próprio serviço PAM). Consumido pela Task 5 (hyprlock não autentica sem isso) e pelas Tasks seguintes que dependem de portals/polkit já estarem de pé.

- [ ] **Step 1: Remover o Plasma de `configuration.nix`**

Em `configuration.nix`, remova a linha:

```nix
  services.desktopManager.plasma6.enable = true;
```

Mantenha `services.displayManager.sddm.enable = true;` (SDDM continua, só o tema muda na Task 4) e `services.xserver.enable = true;` (base pro XWayland).

- [ ] **Step 2: Adicionar os novos módulos aos imports**

Em `configuration.nix`, no bloco `imports`, adicione (o `modules/sddm-theme.nix` só existirá a partir da Task 4, mas listamos os dois já — a Task 4 cria o arquivo):

```nix
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/terminal.nix
      ./modules/fonts.nix
      ./modules/docker.nix
      ./modules/nix-ld.nix
      ./modules/desktop.nix
      ./modules/media.nix
      ./modules/graphics.nix
      ./modules/hardware.nix
      ./modules/hyprland.nix
      ./modules/sddm-theme.nix
    ];
```

- [ ] **Step 3: Remover o Kate de `users.users.thalys.packages`**

Em `configuration.nix`, troque:

```nix
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
```

por:

```nix
    packages = with pkgs; [
    #  thunderbird
    ];
```

- [ ] **Step 4: Criar `modules/hyprland.nix`**

```nix
# modules/hyprland.nix
{ ... }:

{
  programs.hyprland.enable = true;

  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm.wayland.enable = true;

  # hyprlock (diferente do swaylock, já coberto por programs.hyprland.enable)
  # precisa do próprio serviço PAM pra aceitar senha — sem isso o unlock
  # nunca autentica. Ver modules/lock-idle.nix no home-manager.
  security.pam.services.hyprlock = { };
}
```

**IMPORTANTE:** `modules/sddm-theme.nix` ainda não existe — esta task vai FALHAR o build até a Task 4 criar esse arquivo. Rode a verificação da Task 2 e da Task 3 juntas com a Task 4, ou crie um `modules/sddm-theme.nix` vazio (`{ }`) temporário nesta task e substitua na Task 4. Recomendado: criar o placeholder vazio agora para poder validar build incrementalmente.

```nix
# modules/sddm-theme.nix (placeholder temporário, substituído na Task 4)
{ }
```

- [ ] **Step 5: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa sem erro (KDE removido, Hyprland habilitado a nível de sistema).

- [ ] **Step 6: Commit**

```bash
git add configuration.nix modules/hyprland.nix modules/sddm-theme.nix
git commit -m "feat: remove KDE Plasma e habilita Hyprland a nivel de sistema"
```

---

## Task 3: Trocar pacotes do KDE por pacotes do ecossistema Hyprland

**Files:**
- Modify: `modules/desktop.nix`

**Interfaces:**
- Consumes: nada.
- Produces: `nautilus`, `grim`, `slurp`, `wl-clipboard`, `pavucontrol`, `networkmanagerapplet`, `hyprpolkitagent` disponíveis em `environment.systemPackages`. `pkgs.hyprpolkitagent` é referenciado por caminho completo (`${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent`) na Task 5 — precisa estar instalado aqui pra esse caminho existir no sistema final.

- [ ] **Step 1: Editar `modules/desktop.nix`**

```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    vscode

    # API Client
    bruno

    #multimedia
    vlc
    pavucontrol

    #torrent
    qbittorrent

    #browsers
    google-chrome

    #dev
    dbeaver-bin

    #hardware
    openrgb-with-all-plugins

    #terminal
    ghostty

    # Hyprland desktop
    nautilus
    grim
    slurp
    wl-clipboard
    networkmanagerapplet
    hyprpolkitagent
  ];
}
```

Removidos: `kdePackages.kate` (substituído pelo VS Code, já presente), `kdePackages.krdc` (sem substituto neste escopo).

- [ ] **Step 2: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa. `nix eval .#nixosConfigurations.nixos.config.environment.systemPackages --apply "map (p: p.pname or p.name)" --json` deve incluir `nautilus`, `grim`, `slurp`, `wl-clipboard`, `pavucontrol`, `network-manager-applet`, `hyprpolkitagent` e **não** incluir `kate`/`krdc`.

- [ ] **Step 3: Commit**

```bash
git add modules/desktop.nix
git commit -m "feat: troca pacotes KDE por pacotes do ecossistema Hyprland"
```

---

## Task 4: Tema Gruvbox para o SDDM

**Files:**
- Modify: `modules/sddm-theme.nix` (substitui o placeholder `{ }` da Task 2)

**Interfaces:**
- Consumes: paleta de `gruvbox-palette.nix` (Task 1).
- Produces: `services.displayManager.sddm.theme = "sddm-astronaut-theme"` com as chaves de cor do tema `astronaut.conf` sobrescritas para a paleta Gruvbox.

- [ ] **Step 1: Editar `modules/sddm-theme.nix`**

```nix
# modules/sddm-theme.nix
{ pkgs, ... }:
let
  palette = import ../gruvbox-palette.nix;

  theme = pkgs.sddm-astronaut.override {
    themeConfig = {
      HeaderTextColor = "#${palette.fg1}";
      DateTextColor = "#${palette.fg1}";
      TimeTextColor = "#${palette.orange}";

      FormBackgroundColor = "#${palette.bg0}";
      BackgroundColor = "#${palette.bg0}";
      DimBackgroundColor = "#${palette.bg0}";

      LoginFieldBackgroundColor = "#${palette.bg1}";
      PasswordFieldBackgroundColor = "#${palette.bg1}";
      LoginFieldTextColor = "#${palette.fg1}";
      PasswordFieldTextColor = "#${palette.fg1}";
      UserIconColor = "#${palette.fg1}";
      PasswordIconColor = "#${palette.fg1}";

      PlaceholderTextColor = "#${palette.gray}";
      WarningColor = "#${palette.red}";

      LoginButtonTextColor = "#${palette.bg0}";
      LoginButtonBackgroundColor = "#${palette.orange}";
      SystemButtonsIconsColor = "#${palette.fg1}";
      SessionButtonTextColor = "#${palette.fg1}";
      VirtualKeyboardButtonTextColor = "#${palette.fg1}";

      DropdownTextColor = "#${palette.fg1}";
      DropdownSelectedBackgroundColor = "#${palette.bg2}";
      DropdownBackgroundColor = "#${palette.bg0}";

      HighlightTextColor = "#${palette.bg0}";
      HighlightBackgroundColor = "#${palette.orange}";
      HighlightBorderColor = "#${palette.orange}";

      HoverUserIconColor = "#${palette.yellow}";
      HoverPasswordIconColor = "#${palette.yellow}";
      HoverSystemButtonsIconsColor = "#${palette.yellow}";
      HoverSessionButtonTextColor = "#${palette.yellow}";
      HoverVirtualKeyboardButtonTextColor = "#${palette.yellow}";
    };
  };
in
{
  services.displayManager.sddm = {
    theme = "sddm-astronaut-theme";
    extraPackages = [ theme ];
  };
}
```

- [ ] **Step 2: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa, incluindo a compilação da derivação `sddm-astronaut` com o `themeConfig` customizado.

**Fallback se este passo falhar ou o build ficar excessivamente lento/quebrado:** substitua o conteúdo do arquivo por
```nix
{ }
```
temporariamente para desbloquear as próximas tasks, e trate a tematização do SDDM como item avulso a retomar depois — a spec já documenta esse risco.

- [ ] **Step 3: Commit**

```bash
git add modules/sddm-theme.nix
git commit -m "feat: tema Gruvbox para o SDDM (sddm-astronaut-theme)"
```

---

## Task 5: Compositor Hyprland (home-manager)

**Files:**
- Create: `home-modules/hyprland.nix`
- Modify: `home.nix`

**Interfaces:**
- Consumes: paleta de `gruvbox-palette.nix` (Task 1); `pkgs.hyprpolkitagent`, `pkgs.grim`, `pkgs.slurp`, `pkgs.wl-clipboard` (Task 3).
- Produces: variáveis hyprlang `$terminal`, `$fileManager`, `$menu`, `$mod` usadas por outras seções do próprio arquivo. `SUPER+L` invoca `hyprlock` (consumido pela Task 8, que precisa existir para o bind funcionar em runtime — não é uma dependência de build).

- [ ] **Step 1: Criar `home-modules/hyprland.nix`**

```nix
# home-modules/hyprland.nix
{ pkgs, ... }:
let
  palette = import ../gruvbox-palette.nix;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # instalado via programs.hyprland.enable (modules/hyprland.nix)
    portalPackage = null; # idem, xdg-desktop-portal-hyprland já vem de lá

    # home-manager >=26.05 (nosso home.stateVersion) usa por padrão o novo
    # formato de config em Lua. Este rice segue a sintaxe hyprlang clássica
    # (a mesma do JaKooLit/Hyprland-Dots e da wiki do Hyprland).
    configType = "hyprlang";

    settings = {
      monitor = "DP-1,1920x1080@120,0x0,1";

      "$terminal" = "${pkgs.ghostty}/bin/ghostty";
      "$fileManager" = "${pkgs.nautilus}/bin/nautilus";
      "$menu" = "${pkgs.rofi}/bin/rofi -show drun";
      "$mod" = "SUPER";

      exec-once = [
        "waybar"
        "swaync"
        "hyprpaper"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];

      env = [
        "NIXOS_OZONE_WL,1"
        "GTK_IM_MODULE,simple"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "intl";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(${palette.orange}ee) rgba(${palette.yellow}ee) 45deg";
        "col.inactive_border" = "rgba(${palette.bg1}aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        blur = {
          enabled = true;
          size = 3;
          passes = 2;
        };
        shadow = {
          enabled = true;
          range = 10;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures.workspace_swipe = true;

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      bind =
        [
          "$mod, Q, exec, $terminal"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, E, exec, $fileManager"
          "$mod, R, exec, $menu"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, L, exec, hyprlock"
          "$mod, P, pseudo"
          "$mod, J, togglesplit"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          ", Print, exec, ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = toString (i + 1);
            in
            [
              "$mod, ${ws}, workspace, ${ws}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
            ]
          ) 9
        ))
        ++ [
          "$mod, 0, workspace, 10"
          "$mod SHIFT, 0, movetoworkspace, 10"
        ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
```

- [ ] **Step 2: Importar em `home.nix`**

Em `home.nix`, logo após `{ config, pkgs, ... }:`, adicione o bloco `imports` como primeiro atributo (ele vai crescer nas próximas tasks):

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./home-modules/hyprland.nix
  ];

  home.username = "thalys";
  ...
```

- [ ] **Step 3: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa. `nix eval .#nixosConfigurations.nixos.config.home-manager.users.thalys.wayland.windowManager.hyprland.settings.general.layout --json` deve retornar `"dwindle"`.

- [ ] **Step 4: Commit**

```bash
git add home-modules/hyprland.nix home.nix
git commit -m "feat: configura compositor Hyprland via home-manager"
```

---

## Task 6: Waybar

**Files:**
- Create: `home-modules/waybar.nix`
- Modify: `home.nix`

**Interfaces:**
- Consumes: paleta de `gruvbox-palette.nix` (Task 1).
- Produces: nada consumido por outras tasks (waybar é folha na árvore de dependências).

- [ ] **Step 1: Criar `home-modules/waybar.nix`**

```nix
# home-modules/waybar.nix
{ ... }:
let
  palette = import ../gruvbox-palette.nix;
in
{
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 34;
      margin-top = 6;
      margin-left = 10;
      margin-right = 10;
      spacing = 4;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [
        "custom/notification"
        "tray"
        "pulseaudio"
        "network"
        "cpu"
        "memory"
      ];

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
      };

      "hyprland/window" = {
        max-length = 40;
      };

      clock = {
        format = "{:%H:%M   %a %d %b}";
        tooltip-format = "{:%Y-%m-%d}";
      };

      "custom/notification" = {
        tooltip = false;
        format = "{icon}";
        format-icons = {
          notification = "󱅫";
          none = "󰂜";
          "dnd-notification" = "󱏨";
          "dnd-none" = "󰂛";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
      };

      tray.spacing = 10;

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = "  muted";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";
      };

      network = {
        format-wifi = "  {essid}";
        format-ethernet = "  conectado";
        format-disconnected = "  desconectado";
      };

      cpu = {
        format = "  {usage}%";
        interval = 5;
      };

      memory = {
        format = "  {used:0.1f}G";
        interval = 5;
      };
    };

    style = ''
      * {
        font-family: "FiraCode Nerd Font";
        font-size: 13px;
      }

      window#waybar {
        background: transparent;
      }

      #workspaces,
      #window,
      #clock,
      #custom-notification,
      #tray,
      #pulseaudio,
      #network,
      #cpu,
      #memory {
        background-color: #${palette.bg1};
        color: #${palette.fg1};
        border-radius: 12px;
        padding: 0 10px;
        margin: 4px 2px;
      }

      #workspaces button {
        color: #${palette.gray};
        padding: 0 6px;
      }

      #workspaces button.active {
        color: #${palette.orange};
      }

      #clock {
        color: #${palette.yellow};
        font-weight: bold;
      }

      #pulseaudio {
        color: #${palette.aqua};
      }

      #network {
        color: #${palette.blue};
      }

      #cpu,
      #memory {
        color: #${palette.green};
      }
    '';
  };
}
```

- [ ] **Step 2: Importar em `home.nix`**

```nix
  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/waybar.nix
  ];
```

- [ ] **Step 3: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa.

- [ ] **Step 4: Commit**

```bash
git add home-modules/waybar.nix home.nix
git commit -m "feat: adiciona waybar com estilo Gruvbox"
```

---

## Task 7: Rofi (launcher)

**Files:**
- Create: `home-modules/rofi.nix`
- Modify: `home.nix`

**Interfaces:**
- Consumes: nada (usa o tema `gruvbox-dark` que já vem embutido no pacote `rofi` do nixpkgs — confirmado em `share/rofi/themes/gruvbox-dark.rasi`).
- Produces: `${pkgs.rofi}/bin/rofi` (referenciado como `$menu` na Task 5 — dependência apenas de runtime, não de build, já que a Task 5 usa `pkgs.rofi` diretamente).

- [ ] **Step 1: Criar `home-modules/rofi.nix`**

```nix
# home-modules/rofi.nix
{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    theme = "gruvbox-dark";
    font = "FiraCode Nerd Font 12";
  };
}
```

- [ ] **Step 2: Importar em `home.nix`**

```nix
  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/waybar.nix
    ./home-modules/rofi.nix
  ];
```

- [ ] **Step 3: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa.

- [ ] **Step 4: Commit**

```bash
git add home-modules/rofi.nix home.nix
git commit -m "feat: adiciona rofi como launcher (tema gruvbox-dark)"
```

---

## Task 8: Lock screen e idle (hyprlock + hypridle)

**Files:**
- Create: `home-modules/lock-idle.nix`
- Modify: `home.nix`

**Interfaces:**
- Consumes: paleta de `gruvbox-palette.nix` (Task 1); `security.pam.services.hyprlock` já criado a nível de sistema (Task 2) — sem isso o hyprlock nunca aceita a senha digitada.
- Produces: comando `hyprlock` no PATH, referenciado pelo bind `$mod, L` da Task 5 e pelo `lock_cmd`/`on-timeout` do hypridle abaixo (dependência de runtime).

- [ ] **Step 1: Criar `home-modules/lock-idle.nix`**

```nix
# home-modules/lock-idle.nix
{ ... }:
let
  palette = import ../gruvbox-palette.nix;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 2;
          blur_size = 4;
        }
      ];

      input-field = [
        {
          size = "250, 50";
          position = "0, -40";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(${palette.fg1})";
          inner_color = "rgb(${palette.bg1})";
          outer_color = "rgb(${palette.orange})";
          outline_thickness = 3;
          placeholder_text = "Senha...";
          shadow_passes = 2;
        }
      ];

      label = [
        {
          text = "cmd[update:1000] date +'%H:%M'";
          color = "rgb(${palette.fg0})";
          font_size = 64;
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
```

- [ ] **Step 2: Importar em `home.nix`**

```nix
  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/waybar.nix
    ./home-modules/rofi.nix
    ./home-modules/lock-idle.nix
  ];
```

- [ ] **Step 3: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa.

- [ ] **Step 4: Commit**

```bash
git add home-modules/lock-idle.nix home.nix
git commit -m "feat: adiciona hyprlock e hypridle (lock screen e gestao de idle)"
```

---

## Task 9: Notificações (swaync)

**Files:**
- Create: `home-modules/notifications.nix`
- Modify: `home.nix`

**Interfaces:**
- Consumes: paleta de `gruvbox-palette.nix` (Task 1). O módulo `custom/notification` da waybar (Task 6) espera o binário `swaync-client` no PATH — fornecido por este arquivo em runtime.
- Produces: nada consumido por outras tasks no nível de build.

- [ ] **Step 1: Criar `home-modules/notifications.nix`**

```nix
# home-modules/notifications.nix
{ ... }:
let
  palette = import ../gruvbox-palette.nix;
in
{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      notification-icon-size = 48;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 6;
      timeout-low = 3;
      timeout-critical = 0;
    };

    style = ''
      .notification-row .notification-background {
        background: #${palette.bg1};
        border-radius: 12px;
        border: 1px solid #${palette.bg2};
      }

      .notification-row .notification-background .summary {
        color: #${palette.fg1};
        font-weight: bold;
      }

      .notification-row .notification-background .body {
        color: #${palette.fg0};
      }

      .control-center {
        background: #${palette.bg0};
      }

      .widget-title {
        color: #${palette.orange};
      }
    '';
  };
}
```

- [ ] **Step 2: Importar em `home.nix`**

```nix
  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/waybar.nix
    ./home-modules/rofi.nix
    ./home-modules/lock-idle.nix
    ./home-modules/notifications.nix
  ];
```

- [ ] **Step 3: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa.

- [ ] **Step 4: Commit**

```bash
git add home-modules/notifications.nix home.nix
git commit -m "feat: adiciona swaync (central de notificacoes) com estilo Gruvbox"
```

---

## Task 10: Wallpaper (hyprpaper)

**Files:**
- Create: `home-modules/wallpaper.nix`
- Modify: `home.nix`

**Interfaces:**
- Consumes: `config.home.homeDirectory` (padrão do home-manager).
- Produces: nada consumido por outras tasks. O caminho `~/Pictures/wallpapers/wallpaper.jpg` é um placeholder intencional — a spec já define que o wallpaper final é fornecido pelo usuário depois. Sem o arquivo, hyprpaper só loga um erro e mostra fundo preto; não quebra o build nem o resto da sessão.

- [ ] **Step 1: Criar `home-modules/wallpaper.nix`**

```nix
# home-modules/wallpaper.nix
{ config, ... }:
let
  wallpaperPath = "${config.home.homeDirectory}/Pictures/wallpapers/wallpaper.jpg";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ wallpaperPath ];
      wallpaper = [ "DP-1,${wallpaperPath}" ];
    };
  };
}
```

- [ ] **Step 2: Importar em `home.nix`**

```nix
  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/waybar.nix
    ./home-modules/rofi.nix
    ./home-modules/lock-idle.nix
    ./home-modules/notifications.nix
    ./home-modules/wallpaper.nix
  ];
```

- [ ] **Step 3: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa (não depende do arquivo de imagem existir).

- [ ] **Step 4: Commit**

```bash
git add home-modules/wallpaper.nix home.nix
git commit -m "feat: adiciona hyprpaper (wallpaper daemon, caminho placeholder)"
```

---

## Task 11: Tema GTK/Qt e cursor

**Files:**
- Create: `home-modules/theme.nix`
- Modify: `home.nix`

**Interfaces:**
- Consumes: pacotes `pkgs.gruvbox-gtk-theme` (tema `Gruvbox-Dark`), `pkgs.papirus-icon-theme` (`Papirus-Dark`), `pkgs.bibata-cursors` (`Bibata-Modern-Classic`) — todos confirmados existentes no nixpkgs pinado.
- Produces: nada consumido por outras tasks.

- [ ] **Step 1: Criar `home-modules/theme.nix`**

```nix
# home-modules/theme.nix
{ pkgs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    colorScheme = "dark";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };
}
```

- [ ] **Step 2: Importar em `home.nix`**

```nix
  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/waybar.nix
    ./home-modules/rofi.nix
    ./home-modules/lock-idle.nix
    ./home-modules/notifications.nix
    ./home-modules/wallpaper.nix
    ./home-modules/theme.nix
  ];
```

- [ ] **Step 3: Verificar build**

Run: `nixos-rebuild build --flake .#nixos`
Expected: build passa.

- [ ] **Step 4: Commit**

```bash
git add home-modules/theme.nix home.nix
git commit -m "feat: tema GTK/Qt/cursor Gruvbox (Gruvbox-Dark, Papirus-Dark, Bibata)"
```

---

## Task 12: Switch, wallpaper do usuário e checklist de verificação manual

**Files:** nenhum arquivo novo — esta task ativa a configuração e valida a sessão real.

**Interfaces:**
- Consumes: todas as tasks anteriores.

- [ ] **Step 1: Build final completo**

Run: `nixos-rebuild build --flake .#nixos`
Expected: passa limpo, sem warnings de opções conflitantes.

- [ ] **Step 2: Pedir/posicionar o wallpaper do usuário**

```bash
mkdir -p ~/Pictures/wallpapers
# copiar o arquivo de imagem escolhido pelo usuário para:
# ~/Pictures/wallpapers/wallpaper.jpg
```

Se o usuário ainda não tiver escolhido a imagem neste ponto, pule este step — o hyprpaper simplesmente mostra fundo preto até o arquivo existir (não bloqueia o restante da checklist).

- [ ] **Step 3: Aplicar a configuração**

Run: `sudo nixos-rebuild switch --flake .#nixos`
Expected: ativa sem erro. **Não faça logout ainda** — mantenha a sessão KDE atual aberta até confirmar que dá pra voltar (Step 4).

- [ ] **Step 4: Confirmar a rede de segurança do systemd-boot**

Run: `sudo nixos-rebuild list-generations` (ou olhe o menu do systemd-boot no próximo reboot)
Expected: a geração anterior (com Plasma) aparece na lista — se a sessão Hyprland falhar, ela pode ser selecionada no boot.

- [ ] **Step 5: Logout e login na sessão Hyprland**

Na tela do SDDM, selecione a sessão "Hyprland" e faça login.

- [ ] **Step 6: Checklist funcional** (marque cada item manualmente)

- [ ] Waybar sobe no topo da tela com o estilo Gruvbox
- [ ] `SUPER+Q` abre o ghostty
- [ ] `SUPER+R` abre o rofi (tema gruvbox-dark)
- [ ] `SUPER+E` abre o Nautilus
- [ ] `SUPER+1` a `SUPER+0` trocam de workspace
- [ ] Áudio funciona (`pavucontrol` abre e mostra os dispositivos)
- [ ] Ícone de rede (nm-applet) e bluetooth (blueman) aparecem na tray da waybar
- [ ] `SUPER+L` trava a tela via hyprlock e a senha do usuário desbloqueia
- [ ] Depois de alguns minutos sem uso, a tela apaga (dpms off) — hypridle está rodando
- [ ] Uma notificação de teste (`notify-send "teste" "funcionando"`) aparece e some, e o ícone de notificação na waybar reflete isso
- [ ] Compartilhamento de tela funciona em pelo menos um app (ex: abrir uma call de teste no navegador e tentar compartilhar tela) — valida os portals XDG

- [ ] **Step 7: Só depois de todo o checklist passar**

```bash
git log --oneline -15   # confirma que todos os commits das Tasks 1-11 estão presentes
```

Neste ponto — e só neste ponto — é seguro rodar `nix-collect-garbage` se desejado. Não é um step obrigatório do plano, é uma liberação de restrição.
