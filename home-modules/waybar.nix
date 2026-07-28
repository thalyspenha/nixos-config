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
