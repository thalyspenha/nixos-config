# Integrações Externas

Não há integrações de aplicação (webhooks, SDKs de terceiros no código, chamadas a APIs).
As "integrações" deste repositório são: (a) fontes de build do Nix; (b) ferramentas
cliente instaladas para o usuário interagir com serviços externos manualmente.

## Fontes de build (Nix Flake inputs)

Definidas em `flake.nix`, pinadas em `flake.lock`:

| Input | Origem | Ref | Rev pinada (`flake.lock`) |
|---|---|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs` | `nixos-26.05` | `6aefcda9401be8acc2b74244fb3b37520ea1f0a8` (lastModified 1788921488) |
| `home-manager` | `github:nix-community/home-manager` | `release-26.05` | `fd0956c99c41ae3c13a73a638f1f7e963aebc4ab` (lastModified 1788642154); `inputs.nixpkgs.follows = "nixpkgs"` |

`flake.lock` versão 7. Nenhum outro input (sem `nixpkgs-unstable`, sem overlays externos,
sem `nix-darwin`, sem flake-utils).

Durante o build, o Nix também acessa os **caches binários padrão** (`cache.nixos.org`) —
não configurado explicitamente no repo, é o default do NixOS.

## Ferramentas cliente de serviços externos (instaladas, sem credenciais versionadas)

| Ferramenta | Pacote | Módulo | Serviço externo alvo |
|---|---|---|---|
| Google Cloud SDK + `gke-gcloud-auth-plugin` | `google-cloud-sdk.withExtraComponents [...]` | `modules/terminal.nix` | Google Cloud Platform / GKE |
| `kubectl` | `kubectl` | `modules/terminal.nix` | Clusters Kubernetes (config em `~/.kube`, não versionada) |
| `k9s` | `k9s` | `modules/terminal.nix` | Kubernetes (TUI) |
| `android-tools` / `android-studio` | `android-tools`, `android-studio` | `modules/terminal.nix`, `modules/desktop.nix` | Dispositivos Android (ADB) |
| `docker` / `lazydocker` | `virtualisation.docker`, `lazydocker` | `modules/docker.nix`, `modules/terminal.nix` | Registries de container (Docker Hub etc.) |
| `bruno` | `bruno` | `modules/desktop.nix` | Cliente de API REST (coleções não versionadas aqui) |
| `remmina` | `remmina` | `modules/desktop.nix` | Acesso remoto RDP/VNC/SSH |
| `dbeaver-bin` | `dbeaver-bin` | `modules/desktop.nix` | Bancos de dados remotos |
| `proton-vpn` | `proton-vpn` | `modules/desktop.nix` | Proton VPN (adicionado, não commitado) |
| `openvpn` | `openvpn` | `modules/terminal.nix` | Servidores OpenVPN |
| `ente-auth` | `ente-auth` | `modules/desktop.nix` | Ente (2FA/TOTP) (adicionado, não commitado) |
| `google-chrome` / `firefox` | `google-chrome`, `programs.firefox` | `modules/desktop.nix`, `configuration.nix` | Navegadores |
| `picard` + `chromaprint` | `picard`, `chromaprint` | `modules/desktop.nix` | MusicBrainz (metadados de áudio / AcoustID) |
| `uv` | `uv` | `modules/terminal.nix` | PyPI (gestor de pacotes Python) |
| Flatpak | `services.flatpak` | `modules/hardware.nix` | Flathub (repos não adicionados no código — feito manualmente) |

**Nenhuma credencial, token, chave de API ou endpoint privado está no repositório.**
Autenticação dessas ferramentas é feita fora do controle de versão (`~/.config`, `~/.kube`,
`gcloud auth login`, etc.).

## Integrações não identificadas / ausentes

- Webhooks de entrada ou saída: **Não aplicável**.
- Filas externas (SQS, RabbitMQ, Kafka): **Não aplicável** — ver `infrastructure.md`.
- Provedores de e-mail, pagamento, storage (S3/GCS) via código: **Não identificado /
  ausente** (o `google-cloud-sdk` daria acesso a GCS, mas nada é configurado).
- Serviços de observabilidade (Sentry, Datadog): **Ausente**.
