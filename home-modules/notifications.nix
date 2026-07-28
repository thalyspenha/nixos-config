{ ... }:
let
  palette = import ../gruvbox-palette.nix;
in
{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      notification-icon-size = 48;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 6;
      timeout-low = 3;
      timeout-critical = 0;
    };

    style = ''
      .notification-row .notification-background {
        background: #${palette.bg1};
        border-radius: 12px;
        border: 1px solid #${palette.bg2};
      }

      .notification-row .notification-background .summary {
        color: #${palette.fg1};
        font-weight: bold;
      }

      .notification-row .notification-background .body {
        color: #${palette.fg0};
      }

      .control-center {
        background: #${palette.bg0};
      }

      .widget-title {
        color: #${palette.orange};
      }
    '';
  };
}
