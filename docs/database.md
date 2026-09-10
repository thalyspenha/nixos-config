# Banco de dados

## Status: Não aplicável

Este repositório é uma configuração de sistema NixOS. **Não há banco de dados, esquema,
migrações, entidades ou relacionamentos** definidos ou geridos por este projeto.

## Itens do roteiro

| Item | Situação |
|---|---|
| Banco de dados (engine, schema) | **Não aplicável** — nenhum banco é declarado ou provisionado |
| Entidades | **Não aplicável** |
| Relacionamentos | **Não aplicável** |
| Migrações | **Não aplicável** |
| ORM / camada de acesso | **Não aplicável** |

## Observações (ferramentas relacionadas, não bancos geridos)

- `dbeaver-bin` está instalado (`modules/desktop.nix`) — é um **cliente** de banco de
  dados de uso geral do usuário, sem configuração de conexão versionada neste repositório.
- `virtualisation.docker.enable` (`modules/docker.nix`) permitiria ao usuário rodar
  bancos em containers manualmente, mas **nenhum** `docker-compose.yml`, `Dockerfile` ou
  serviço de banco existe no repositório.
- Não há `services.postgresql`, `services.mysql`, `services.redis`, `services.mongodb`
  ou similar em nenhum módulo.

## "Database versions" no sentido do NixOS

`system.stateVersion = "26.05"` e `home.stateVersion = "26.05"` controlam defaults de
dados com estado (formatos de arquivos de serviços, versões default de bancos de serviços
do NixOS *se algum fosse habilitado*). Nenhum serviço com estado desse tipo está
habilitado atualmente.
