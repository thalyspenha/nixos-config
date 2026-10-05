# Decisões (ADR resumido) e Verificação Cruzada

Este documento tem duas partes:
1. Decisões técnicas inferidas do código e do histórico Git.
2. Verificação cruzada entre esta documentação e o código atual (inconsistências).

---

## Parte 1 — Decisões

As decisões abaixo são **inferidas** do código e das mensagens de commit. Onde há um
documento de spec, ele é citado.

### D1 — Nix Flakes como modelo de configuração
- **O quê:** o repo é um flake (`flake.nix` + `flake.lock`); `nix.settings.experimental-features = [ "nix-command" "flakes" ]`.
- **Evidência:** commit `bdd7afe` "flakes do nixos".
- **Consequência:** dependências pinadas e reproduzíveis; aplicação via `nixos-rebuild switch --flake`.

### D2 — Home Manager integrado como módulo NixOS (não standalone)
- **O quê:** `flake.nix` inclui `home-manager.nixosModules.home-manager`; `configuration.nix` faz `home-manager.users.thalys = import ./home.nix` com `useGlobalPkgs`/`useUserPackages`.
- **Consequência:** uma única invocação (`nixos-rebuild switch`) aplica sistema + usuário; `home.nix` é avaliado junto com o sistema.

### D3 — Canal único `nixos-26.05` (estável), sem `unstable`
- **Evidência:** `flake.nix` inputs; `home-manager` segue o mesmo nixpkgs (`follows`).
- **Consequência:** menos churn; pacotes muito recentes podem não estar disponíveis.

### D4 — Configuração modularizada por área em `modules/`
- **O quê:** `configuration.nix` só agrega; cada preocupação (terminal, fonts, docker, desktop, media, graphics, hardware, nix-ld) é um arquivo.
- **Evidência:** estrutura de `modules/` + seção "Estrutura" do `README.md`.

### D5 — Ambiente de desktop: histórico de trocas, hoje **KDE Plasma**
- **Linha do tempo (Git):**
  - Início: KDE Plasma (`services.desktopManager.plasma6`).
  - `cbdc1a6`..`b2f0d75` (jul/2026): migração para **Hyprland** (com specs em `docs/superpowers/`).
  - `c2254bc`, `d560a6e`, `d740421`, `7a2473a`, `ec42f2d`: **revert** Hyprland → KDE Plasma (spec: `docs/superpowers/specs/2026-07-29-kde-revert-design.md`).
  - `5b585dd` "retornado para kde".
  - `0dc301b` "removido kde e colocado gnome" → GNOME (`gdm` + `desktopManager.gnome`).
  - volta ao KDE → **estado atual**: `services.displayManager.sddm.enable` (Wayland) + `services.desktopManager.plasma6.enable`.
- **Consequência:** os documentos em `docs/superpowers/` refletem o ciclo Hyprland↔KDE (histórico; ver Parte 2, I1).

### D6 — VS Code gerido pelo Home Manager (declarativo)
- **O quê:** `programs.vscode` em `home.nix` com extensions e `userSettings`; `vscode` foi **removido** de `modules/desktop.nix` (`git diff` atual).
- **Consequência:** extensões e settings versionados; o diretório de config do VS Code passa a ser (parcialmente) gerido pelo Nix.

### D7 — `nix-ld` para binários dinâmicos não-Nix
- **O quê:** `modules/nix-ld.nix` com um conjunto de libs comuns.
- **Motivação (inferida):** rodar ferramentas baixadas por IDEs/SDKs (.NET, Python, Android Studio) que esperam um FHS.

### D8 — Locale pt_BR + teclado US-Internacional
- **O quê:** `i18n.defaultLocale = "pt_BR.UTF-8"` (+ todas `LC_*`), X11 `us`/`intl`, console `us-acentos`.
- **Histórico:** commits `af40e1b`, `b2f0d75`/`bf16077` tratam acentuação e teclas de mídia.

### D9 — PipeWire em vez de PulseAudio
- **O quê:** `services.pulseaudio.enable = false`; `services.pipewire` com ALSA/Pulse/32-bit + `rtkit`.

### D10 — Docker "puro" (sem compose versionado), acesso via grupo
- **O quê:** `virtualisation.docker.enable`; `thalys` no grupo `docker`.
- **Consequência de segurança:** grupo `docker` ≈ root. Nenhum modo rootless.

### D11 — Kernel mais recente
- **O quê:** `boot.kernelPackages = pkgs.linuxPackages_latest`.
- **Trade-off:** hardware novo funciona melhor; risco de regressões de kernel.

### D12 — `allowUnfree = true`
- Necessário para Chrome, Android Studio, google-cloud-sdk, VS Code (marketplace da MS via nixpkgs), etc.

### D13 — Fluxo de mudança guiado por spec/plano ("superpowers")
- **Evidência:** `docs/superpowers/specs/` e `docs/superpowers/plans/` com specs e planos de execução passo-a-passo; commits `docs:` correspondentes.
- **Regra derivada:** cada tarefa deve deixar o flake avaliável (`nix build ... --dry-run` passa) antes do commit.

### D14 — `nixos-rebuild switch` é ação manual do usuário
- **Evidência:** seção "Validação" de `docs/superpowers/specs/2026-07-29-kde-revert-design.md` e "Global Constraints" do plano: trocar de sessão gráfica em produção deve ser confirmado e executado pelo próprio usuário.

### Decisões não documentadas / não identificadas
- Escolha da GPU/driver (nada específico além de `mesa` genérico) — **Não identificado.**
- Estratégia de backup / criptografia de disco (sem LUKS no `hardware-configuration.nix`) — **Não identificado** (aparenta não haver).
- Por que `flatpak` está habilitado junto com uma config Nix declarativa — **Não identificado** (nenhum remote/app Flatpak versionado).

---

## Parte 2 — Verificação cruzada (documentação × código)

Método: releitura de todos os `.nix`, `README.md`, `flake.lock`, `git diff`, `git log`
e dos `docs/superpowers/*` em 2026-09-10, comparando com o que esta documentação afirma.

> **Nota (2026-09-10):** I1–I4 foram corrigidos após a análise inicial. As entradas abaixo
> mantêm a descrição do problema seguida de **✅ Corrigido** com o que foi feito.
> I5–I7 permanecem como registro (não são defeitos acionáveis).

### I1 — `docs/superpowers/*` desatualizado (histórico)
- **Onde:** `docs/superpowers/specs/2026-07-29-kde-revert-design.md`,
  `docs/superpowers/plans/2026-07-29-kde-revert.md`.
- **Discrepância:** ambos descrevem o estado final como **KDE Plasma**
  (`services.desktopManager.plasma6.enable = true`). Depois disso o host
  passou por GNOME (`0dc301b`) e voltou ao **KDE Plasma 6** (estado atual, com SDDM
  Wayland), então o estado final descrito coincide de novo com o código.
- **Severidade:** média (docs históricos, mas podem confundir).
- **✅ Corrigido:** adicionado um bloco **STATUS: CONCLUÍDO / HISTÓRICO** no topo de ambos
  os arquivos, esclarecendo que o revert foi executado e que o estado atual é KDE Plasma, com
  ponteiro para `docs/architecture.md`.

### I2 — VS Code: `iconTheme` aponta para extensão não instalada
- **Onde:** `home.nix` — `programs.vscode.profiles.default`.
- **Discrepância:** `userSettings."workbench.iconTheme" = "vscode-icons"`, mas a extensão
  de ícones declarada em `extensions` é `pkief.material-icon-theme`. A extensão
  `vscode-icons` (`vscode-icons-team.vscode-icons`) **não** está na lista.
- **Efeito:** o VS Code ignorava o tema de ícones (usava o default), já que `vscode-icons`
  não estava disponível.
- **Severidade:** baixa (cosmético).
- **✅ Corrigido:** `home.nix:82` alterado para
  `"workbench.iconTheme" = "material-icon-theme";` (id do tema contribuído pela extensão
  já instalada `pkief.material-icon-theme`). Nenhuma extensão adicionada/removida.

### I3 — `README.md` "Estrutura" lista apenas 5 de 9 imports
- **Onde:** `README.md`.
- **Discrepância:** a seção "Estrutura" citava `terminal.nix`, `desktop.nix`, `graphics.nix`,
  `fonts.nix`, `home.nix`. Não mencionava `docker.nix`, `media.nix`, `hardware.nix`,
  `nix-ld.nix` nem `hardware-configuration.nix`.
- **Severidade:** baixa (README incompleto, não incorreto).
- **✅ Corrigido:** `README.md` reescrito — a seção "Estrutura" agora lista todos os
  arquivos (flake, `configuration.nix`, `hardware-configuration.nix`, `home.nix` e os 7
  módulos), com ponteiros para `docs/` e `CLAUDE.md`.

### I4 — `README.md` assume o repo em `/etc/nixos`
- **Onde:** `README.md` — `sudo nixos-rebuild switch --flake /etc/nixos#nixos`.
- **Observação:** a working copy está em `/home/thalys/Projects/Pessoal/nixos-config`.
  Para o comando funcionar como estava, o conteúdo precisa estar em `/etc/nixos`.
- **✅ Corrigido:** `README.md` agora explicita a pré-condição e documenta a alternativa
  `--flake .#nixos` (rodando a partir do diretório do repositório). O comando original
  foi mantido. **Não identificado** se o host usa cópia ou symlink para `/etc/nixos`.

### I5 — Assinaturas de função com parâmetros não usados
- **Onde:** `configuration.nix` (`{ config, pkgs, lib, ... }` — `config` e `lib` não
  usados no corpo; `lib` adicionado no `git diff` atual não commitado),
  `home.nix` (`{ config, pkgs, lib, ... }` — só `pkgs` é usado).
- **Severidade:** nula (idiomático em Nix), apenas registro.

### I6 — Alterações não commitadas na árvore de trabalho (em 2026-09-10)
Não são inconsistências da doc, mas a doc foi escrita **incluindo** estas mudanças:
- `hardware-configuration.nix`: UUIDs de `/`, `/boot` e swap trocadas (reinstalação/novo disco).
- `configuration.nix`: `lib` adicionado à assinatura; bloco
  `environment.sessionVariables.GTK_IM_MODULE = "simple"` **removido**.
- `modules/desktop.nix`: `vscode` removido; `ente-auth`, `proton-vpn`, `gnome-tweaks`
  adicionados.
- `flake.lock`: `nixpkgs` e `home-manager` atualizados (`nix flake update`).

### I7 — Mensagens de commit x conteúdo
- **Onde:** commit `84a12a0` "adicionado fuse lib" — o diff adiciona `kooha` e
  `kdePackages.kdenlive` a `desktop.nix` e um pacote a `terminal.nix` (além de
  `flake.lock`). `kooha`/`kdenlive`/`qbittorrent` foram removidos depois. Sem impacto no
  estado atual; registrado apenas por rastreabilidade.

### Itens verificados SEM discrepância
- Lista de pacotes em `docs/modules.md` e `docs/dependencies.md` confere 1:1 com os
  `.nix` (incluindo alterações não commitadas).
- `flake.lock` revs conferem com `docs/integrations.md` e `docs/dependencies.md`.
- `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run` → exit 0
  (conforme `docs/testing.md`).
- Grupos do usuário (`networkmanager`, `wheel`, `adbusers`, `docker`, `i2c`) conferem
  com `docs/business-rules.md`.
- Ausência de banco de dados, API, filas, testes e CI confirmada por busca em toda a
  árvore (`docs/database.md`, `docs/api.md`, `docs/infrastructure.md`, `docs/testing.md`).
