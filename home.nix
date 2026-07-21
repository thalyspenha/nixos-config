{ config, pkgs, ... }:

{
  home.username = "thalys";
  home.homeDirectory = "/home/thalys";

  home.stateVersion = "26.05";

  home.sessionPath = [
  "$HOME/.local/bin"
];

  programs.home-manager.enable = true;

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

  extensions = with pkgs.vscode-extensions; [
    ms-dotnettools.csharp
    ms-dotnettools.vscode-dotnet-runtime
    ms-python.python
    ms-azuretools.vscode-docker
  ];

  userSettings = {
    "editor.fontFamily" = "'FiraCode Nerd Font Mono'";
    "editor.fontLigatures" = true;
    "editor.formatOnSave" = true;
  };
};
}
