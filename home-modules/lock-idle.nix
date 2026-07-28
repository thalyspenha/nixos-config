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
