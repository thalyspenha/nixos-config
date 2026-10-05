{ config, pkgs, lib, ... }:

{
  imports = [
  ];

  home.username = "thalys";
  home.homeDirectory = "/home/thalys";

  home.stateVersion = "26.05";

  # Compose: no us-intl o padrão é ' + c = ć; aqui fica como no Mac (' + c = ç).
  # Lido pelo fcitx5 e pelo compose do X11/GTK.
  home.file.".XCompose".text = ''
    include "%L"

    <dead_acute> <c> : "ç" ccedilla
    <dead_acute> <C> : "Ç" Ccedilla
  '';

  home.sessionPath = [
  "$HOME/.local/bin"
];

  programs.home-manager.enable = true;

  home.activation.clean-plasma-launchers = lib.hm.dag.entryAfter ["writeBoundary"] ''
    sed -i 's|file:///nix/store/[^/]*/share/applications/|applications:|g' ${config.home.homeDirectory}/.config/plasma-org.kde.plasma.desktop-appletsrc || true
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -lah --icons --git";
      cat = "bat";
      grep = "rg";
      ff = "fastfetch";
      dc = "docker compose";
    };
  };

  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      directory = {
        style = "bold blue";
      };

      git_branch = {
        symbol = "🌱 ";
      };
    };
  };

  programs.vscode = {
  enable = true;

  profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      ms-dotnettools.csharp
      ms-dotnettools.vscode-dotnet-runtime
      ms-python.python
      ms-azuretools.vscode-docker
      ms-dotnettools.csdevkit
      usernamehw.errorlens
      esbenp.prettier-vscode
      pkgs.vscode-extensions.pkief.material-icon-theme
      sdras.night-owl
    ];

    userSettings = {
      "editor.fontFamily" = "FiraCode Nerd Font Mono";
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.colorTheme" = "Night Owl";
      "editor.codeActionsOnSave" = {
        "source.fixAll" = "always";
      };
    };
  };
};
}
