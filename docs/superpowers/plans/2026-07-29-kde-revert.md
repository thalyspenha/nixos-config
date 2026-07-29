# Reverter Hyprland -> KDE Plasma Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the Hyprland desktop setup completely and restore KDE Plasma as the session, matching the pre-migration state (commit `af40e1b`).

**Architecture:** This is a NixOS config repo, not an application — there is no unit test suite. The equivalent of "run the tests" here is `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run` from the repo root, which evaluates the whole flake (`configuration.nix` + `home.nix` together, since `configuration.nix:129` wires `home-manager.users.thalys = import ./home.nix;`) without building or switching. The revert is split into two independently-buildable tasks — system side first, then home-manager side — plus a doc-cleanup task with no build impact.

**Tech Stack:** NixOS, home-manager, Nix flakes.

## Global Constraints

- Do not run `sudo nixos-rebuild switch` as part of this plan — switching the live desktop session is a disruptive, user-facing action (logout/relogin) and must be confirmed and run by the user themselves, per the spec's Validation section.
- Every task must leave the flake in an evaluable state (`--dry-run` succeeds) — never commit a task that leaves dangling imports.
- Full scope and file list is defined in `docs/superpowers/specs/2026-07-29-kde-revert-design.md` — this plan implements exactly that scope, nothing more.

---

## File Structure

| File | Action |
|---|---|
| `modules/hyprland.nix` | Delete |
| `modules/sddm-theme.nix` | Delete |
| `configuration.nix` | Modify: drop 2 imports, add `services.desktopManager.plasma6.enable = true;` |
| `modules/desktop.nix` | Modify: drop Hyprland-only packages, restore `kdePackages.kate` + `kdePackages.krdc` |
| `home-modules/hyprland.nix` | Delete |
| `home-modules/waybar.nix` | Delete |
| `home-modules/rofi.nix` | Delete |
| `home-modules/lock-idle.nix` | Delete |
| `home-modules/notifications.nix` | Delete |
| `home-modules/wallpaper.nix` | Delete |
| `home-modules/theme.nix` | Delete |
| `gruvbox-palette.nix` | Delete |
| `home.nix` | Modify: drop 7 imports |
| `docs/superpowers/plans/2026-07-28-hyprland-migration.md` | Delete |
| `docs/superpowers/specs/2026-07-28-hyprland-migration-design.md` | Delete |

---

### Task 1: System-level revert (configuration.nix, modules/desktop.nix)

At this point `home-modules/*.nix` and `gruvbox-palette.nix` still exist untouched, so the flake stays evaluable through this task on its own.

**Files:**
- Delete: `modules/hyprland.nix`
- Delete: `modules/sddm-theme.nix`
- Modify: `configuration.nix` (imports list + KDE enable line)
- Modify: `modules/desktop.nix` (package list)

**Interfaces:** None — this task doesn't produce anything consumed by later tasks; Task 2 only needs the repo to still evaluate.

- [ ] **Step 1: Delete the two Hyprland-only system modules**

```bash
git rm modules/hyprland.nix modules/sddm-theme.nix
```

- [ ] **Step 2: Remove their imports from configuration.nix and re-enable Plasma**

In `configuration.nix`, the imports list currently reads:

```nix
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/terminal.nix
      ./modules/fonts.nix
      ./modules/docker.nix
      ./modules/nix-ld.nix
      ./modules/desktop.nix
      ./modules/media.nix
      ./modules/graphics.nix
      ./modules/hardware.nix
      ./modules/hyprland.nix
      ./modules/sddm-theme.nix
    ];
```

Change it to:

```nix
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/terminal.nix
      ./modules/fonts.nix
      ./modules/docker.nix
      ./modules/nix-ld.nix
      ./modules/desktop.nix
      ./modules/media.nix
      ./modules/graphics.nix
      ./modules/hardware.nix
    ];
```

Further down, the KDE section currently reads:

```nix
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;

  # Configure keymap in X11
```

Change it to:

```nix
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
```

- [ ] **Step 3: Restore modules/desktop.nix to the pre-migration package list**

Replace the full contents of `modules/desktop.nix` with:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    vscode
    kdePackages.kate

    # API Client
    bruno

    # Acesso remoto
    kdePackages.krdc

    #multimedia
    vlc

    #torrent
    qbittorrent

    #browsers
    google-chrome

    #dev
    dbeaver-bin

    #hardware
    openrgb-with-all-plugins

    #terminal
    ghostty

  ];
}
```

- [ ] **Step 4: Validate the flake still evaluates**

Run: `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run`
Expected: exits 0, no error output (home-modules/*.nix and gruvbox-palette.nix still exist at this point, so home-manager side is untouched and still valid).

- [ ] **Step 5: Commit**

```bash
git add modules/hyprland.nix modules/sddm-theme.nix configuration.nix modules/desktop.nix
git commit -m "revert: remove Hyprland a nivel de sistema, volta KDE Plasma"
```

---

### Task 2: Home-manager cleanup (Hyprland home-modules + palette)

**Files:**
- Delete: `home-modules/hyprland.nix`, `home-modules/waybar.nix`, `home-modules/rofi.nix`, `home-modules/lock-idle.nix`, `home-modules/notifications.nix`, `home-modules/wallpaper.nix`, `home-modules/theme.nix`
- Delete: `gruvbox-palette.nix`
- Modify: `home.nix` (imports list)

**Interfaces:** Consumes nothing from Task 1 directly — only depends on Task 1 having already removed `modules/sddm-theme.nix` (the only system-side consumer of `gruvbox-palette.nix`), so deleting the palette here doesn't leave a dangling reference.

- [ ] **Step 1: Delete the Hyprland home-manager modules and the shared palette**

```bash
git rm home-modules/hyprland.nix home-modules/waybar.nix home-modules/rofi.nix \
       home-modules/lock-idle.nix home-modules/notifications.nix \
       home-modules/wallpaper.nix home-modules/theme.nix gruvbox-palette.nix
```

- [ ] **Step 2: Remove their imports from home.nix**

In `home.nix`, the imports list currently reads:

```nix
  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/waybar.nix
    ./home-modules/rofi.nix
    ./home-modules/lock-idle.nix
    ./home-modules/notifications.nix
    ./home-modules/wallpaper.nix
    ./home-modules/theme.nix
  ];
```

Change it to:

```nix
  imports = [
  ];
```

- [ ] **Step 3: Validate the full flake evaluates**

Run: `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run`
Expected: exits 0, no error output. This is the first point where a stale reference to any deleted home-module or to `gruvbox-palette.nix` would surface as an eval error, since both configuration.nix and home.nix have now been fully reverted.

- [ ] **Step 4: Commit**

```bash
git add home-modules home.nix
git commit -m "revert: remove modulos home-manager do Hyprland (waybar, rofi, hyprlock, tema, wallpaper)"
```

---

### Task 3: Delete obsolete Hyprland migration docs

**Files:**
- Delete: `docs/superpowers/plans/2026-07-28-hyprland-migration.md`
- Delete: `docs/superpowers/specs/2026-07-28-hyprland-migration-design.md`

**Interfaces:** None — pure documentation cleanup, no build impact.

- [ ] **Step 1: Delete the two obsolete docs**

```bash
git rm docs/superpowers/plans/2026-07-28-hyprland-migration.md \
       docs/superpowers/specs/2026-07-28-hyprland-migration-design.md
```

- [ ] **Step 2: Confirm nothing else references them**

Run: `grep -rn "hyprland-migration" docs/ 2>/dev/null`
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add -u docs/superpowers
git commit -m "docs: remove spec/plano obsoletos da migracao Hyprland"
```
