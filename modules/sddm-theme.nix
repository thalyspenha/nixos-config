{ pkgs, ... }:
let
  palette = import ../gruvbox-palette.nix;

  theme = pkgs.sddm-astronaut.override {
    themeConfig = {
      HeaderTextColor = "#${palette.fg1}";
      DateTextColor = "#${palette.fg1}";
      TimeTextColor = "#${palette.orange}";

      FormBackgroundColor = "#${palette.bg0}";
      BackgroundColor = "#${palette.bg0}";
      DimBackgroundColor = "#${palette.bg0}";

      LoginFieldBackgroundColor = "#${palette.bg1}";
      PasswordFieldBackgroundColor = "#${palette.bg1}";
      LoginFieldTextColor = "#${palette.fg1}";
      PasswordFieldTextColor = "#${palette.fg1}";
      UserIconColor = "#${palette.fg1}";
      PasswordIconColor = "#${palette.fg1}";

      PlaceholderTextColor = "#${palette.gray}";
      WarningColor = "#${palette.red}";

      LoginButtonTextColor = "#${palette.bg0}";
      LoginButtonBackgroundColor = "#${palette.orange}";
      SystemButtonsIconsColor = "#${palette.fg1}";
      SessionButtonTextColor = "#${palette.fg1}";
      VirtualKeyboardButtonTextColor = "#${palette.fg1}";

      DropdownTextColor = "#${palette.fg1}";
      DropdownSelectedBackgroundColor = "#${palette.bg2}";
      DropdownBackgroundColor = "#${palette.bg0}";

      HighlightTextColor = "#${palette.bg0}";
      HighlightBackgroundColor = "#${palette.orange}";
      HighlightBorderColor = "#${palette.orange}";

      HoverUserIconColor = "#${palette.yellow}";
      HoverPasswordIconColor = "#${palette.yellow}";
      HoverSystemButtonsIconsColor = "#${palette.yellow}";
      HoverSessionButtonTextColor = "#${palette.yellow}";
      HoverVirtualKeyboardButtonTextColor = "#${palette.yellow}";
    };
  };
in
{
  environment.systemPackages = [ theme ];

  services.displayManager.sddm = {
    theme = "sddm-astronaut-theme";
    extraPackages = [ theme ];
  };
}
