# CLAUDE.md

## 1. Contexto essencial

Configuração declarativa de **um único host NixOS pessoal** (hostname `nixos`, usuário
`thalys`), versionada como Nix Flake. **Não é uma aplicação** — não há código de
aplicação, banco de dados, API, filas nem testes. O repositório de trabalho fica em
`/home/thalys/Projects/Pessoal/nixos-config`; o host aplica a config a partir de
`/etc/nixos`.

## 2. Stack

- **Nix Flakes** + **NixOS** canal `nixos-26.05` (`x86_64-linux`)
- **Home Manager** `release-26.05`, integrado como módulo NixOS (não standalone)
- Host: CPU/placa **AMD**, boot **UEFI + systemd-boot**, kernel `linuxPackages_latest`
- Desktop atual: **KDE Plasma 6** + **SDDM** (Wayland/X11)
- Áudio **PipeWire**; **Docker** habilitado; `nix-ld` para binários não-Nix
- Shell **zsh** + **starship** + **direnv**; editor **VS Code** (gerido via Home Manager)

## 3. Arquitetura resumida

```
flake.nix ──> nixosConfigurations.nixos
   ├── configuration.nix            (agregador do sistema)
   │     ├── hardware-configuration.nix   (gerado — NÃO editar manualmente)
   │     └── modules/*.nix          terminal, fonts, docker, nix-ld,
   │                                desktop, media, graphics, hardware
   └── home-manager ──> home.nix    (usuário thalys: zsh, starship, direnv, vscode)
```

`configuration.nix` só agrega e define sistema (boot, rede, locale, serviços, usuário).
Cada `modules/*.nix` cobre uma área. `home.nix` tem `imports = []` (sem submódulos hoje).
Detalhes em `docs/`.

## 4. Regras importantes

- **Nunca rodar `sudo nixos-rebuild switch` automaticamente** — troca a sessão gráfica em
  produção (logout/relogin). Só o usuário executa. (Ver `docs/decisions.md` D14.)
- **Não editar `hardware-configuration.nix`** manualmente — é gerado por
  `nixos-generate-config`.
- Toda mudança deve deixar o flake **avaliável** antes de commitar:
  `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run` (exit 0).
  Nunca commitar um `import` pendente/quebrado.
- Este repo **não tem suíte de testes**; o `--dry-run` acima é a verificação equivalente.
- Não introduzir banco de dados, serviço de rede exposto ou segredo em texto plano sem o
  usuário pedir explicitamente. Grupo `docker` já equivale a root — ter isso em mente.
- Alterações são guiadas por spec + plano em `docs/superpowers/` quando o escopo é grande.

## 5. Convenções de desenvolvimento

- **Um arquivo por área** em `modules/`; adicionar novo módulo = criar `modules/x.nix` +
  incluir em `imports` de `configuration.nix`.
- Config do usuário vai em `home.nix` (ou futuro `home-modules/`), config de sistema em
  `modules/`.
- Comentários e mensagens de commit em **português**; commits curtos, muitos usam prefixo
  Conventional Commits (`feat:`, `fix:`, `docs:`, `revert:`, `chore:`), outros são frases
  livres ("adicionado ...", "removido ...").
- Pacotes agrupados por categoria com comentário (`# Editor`, `#browsers`, `#dev`, ...).
- Preferir opções `programs.*` / `services.*` do NixOS a instalar pacotes soltos quando
  existir.
- VS Code: extensões e settings declarados em `home.nix` (`programs.vscode`), não pela UI.
- Atualizar dependências: `nix flake update` (regenera `flake.lock`).

## 6. Documentação

A análise completa do projeto está em `/docs`:

| Arquivo | Conteúdo |
|---|---|
| `docs/architecture.md` | Natureza do projeto, camadas, modelo de execução, boot |
| `docs/modules.md` | Cada `.nix` em detalhe (opções e pacotes) |
| `docs/database.md` | Não aplicável (sem banco) — justificado |
| `docs/api.md` | Não aplicável (sem API); lista de serviços systemd e portas |
| `docs/business-rules.md` | Regras de configuração (usuário, grupos, locale, áudio, Nix) |
| `docs/integrations.md` | Flake inputs, caches, ferramentas cliente de serviços externos |
| `docs/infrastructure.md` | Host, Docker, k8s (cliente), rede, firewall, filas, auth, fluxos operacionais |
| `docs/testing.md` | Ausência de testes/CI e a verificação equivalente (`--dry-run`) |
| `docs/dependencies.md` | Inputs pinados + todos os pacotes por módulo |
| `docs/decisions.md` | ADR resumido + **verificação cruzada doc × código (inconsistências I1–I7)** |

Docs históricos de mudança: `docs/superpowers/specs/` e `docs/superpowers/plans/`
(descrevem o ciclo Hyprland↔KDE, já concluído; cada um traz um bloco **STATUS:
CONCLUÍDO / HISTÓRICO** no topo — o estado atual é KDE Plasma).

Comandos essenciais: ver `README.md`.
