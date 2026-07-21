# NixOS Configuration

## Aplicar alterações

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## Atualizar os inputs

```bash
nix flake update
```

## Estrutura

- terminal.nix → ferramentas CLI
- desktop.nix → aplicativos gráficos
- graphics.nix → drivers e aceleração
- fonts.nix → fontes
- home.nix → configurações do usuário