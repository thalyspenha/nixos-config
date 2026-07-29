# home-modules/hyprland.nix
{ pkgs, ... }:
let
  palette = import ../gruvbox-palette.nix;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # instalado via programs.hyprland.enable (modules/hyprland.nix)
    portalPackage = null; # idem, xdg-desktop-portal-hyprland já vem de lá

    # home-manager >=26.05 (nosso home.stateVersion) usa por padrão o novo
    # formato de config em Lua. Este rice segue a sintaxe hyprlang clássica
    # (a mesma do JaKooLit/Hyprland-Dots e da wiki do Hyprland).
    configType = "hyprlang";

    settings = {
      monitor = "DP-1,1920x1080@120,0x0,1";

      "$terminal" = "${pkgs.ghostty}/bin/ghostty";
      "$fileManager" = "${pkgs.nautilus}/bin/nautilus";
      "$menu" = "${pkgs.rofi}/bin/rofi -show drun";
      "$mod" = "SUPER";

      exec-once = [
        "waybar"
        "nm-applet --indicator"
        "blueman-applet"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];

      env = [
        "NIXOS_OZONE_WL,1"
        "GTK_IM_MODULE,simple"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "intl";
        follow_mouse = 1;
        sensitivity = -0.7;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(${palette.orange}ee) rgba(${palette.yellow}ee) 45deg";
        "col.inactive_border" = "rgba(${palette.bg1}aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        blur = {
          enabled = true;
          size = 3;
          passes = 2;
        };
        shadow = {
          enabled = true;
          range = 10;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        preserve_split = true;
      };

      gesture = [ "3, horizontal, workspace" ];

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      bind =
        [
          "$mod, Q, exec, $terminal"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, E, exec, $fileManager"
          "$mod, R, exec, $menu"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, L, exec, hyprlock"
          "$mod, P, pseudo"
          "$mod, J, layoutmsg, togglesplit"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          ", Print, exec, ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
          ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = toString (i + 1);
            in
            [
              "$mod, ${ws}, workspace, ${ws}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
            ]
          ) 9
        ))
        ++ [
          "$mod, 0, workspace, 10"
          "$mod SHIFT, 0, movetoworkspace, 10"
        ];

      binde = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
