# Testes

## Status: Não há suíte de testes

Não existe framework de testes, arquivos de teste, nem CI. Isso é explicitamente
reconhecido em `docs/superpowers/plans/2026-07-29-kde-revert.md`:

> "This is a NixOS config repo, not an application — there is no unit test suite."

## Verificação equivalente

O análogo de "rodar os testes" para este repositório é **avaliar o flake sem construir
nem aplicar**:

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run
```

- Avalia `configuration.nix` + `home.nix` juntos (o Home Manager é integrado como módulo
  NixOS via `configuration.nix`, `home-manager.users.thalys = import ./home.nix`).
- Sucesso (exit 0) = a configuração é sintática e semanticamente avaliável e todos os
  imports resolvem.
- **Não** valida runtime (serviços iniciando, sessão gráfica funcionando, etc.).

**Verificado em 2026-09-10:** o comando acima retornou exit 0 (com aviso
`Git tree ... is dirty`, esperado por causa de alterações não commitadas).

## Validações mais fortes (não automatizadas no repo)

| Nível | Comando | Observação |
|---|---|---|
| Avaliação | `nix build ... --dry-run` | acima |
| Build completo sem ativar | `nixos-rebuild dry-build --flake .#nixos` ou `nixos-rebuild build --flake .#nixos` | citado no spec `2026-07-29-kde-revert-design.md` |
| Aplicação real | `sudo nixos-rebuild switch --flake /etc/nixos#nixos` | ação com efeito colateral (troca de sessão); o spec exige que seja feita **manualmente pelo usuário**, nunca por um agente automatizado |
| Lint/format | `nixpkgs-fmt` / `alejandra` / `statix` / `deadnix` | **não configurados** no repo |

## CI

**Ausente.** Sem `.github/`, sem hooks de pre-commit versionados, sem Hydra.

## Convenção de teste durante mudanças (dos docs superpowers)

O plano `2026-07-29-kde-revert.md` estabelece: toda tarefa deve deixar o flake em estado
avaliável (`--dry-run` passa) antes de commitar — nunca commitar um import pendente/quebrado.
