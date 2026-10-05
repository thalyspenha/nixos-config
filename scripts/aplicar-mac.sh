#!/usr/bin/env bash
# Aplica visual estilo macOS no KDE Plasma 6 (rode após o nixos-rebuild)
set -e

# Tema global, cores, ícones, cursor
lookandfeeltool -a com.github.vinceliuice.WhiteSur || true
plasma-apply-colorscheme WhiteSur || true
plasma-apply-cursortheme WhiteSur-cursors || true
/run/current-system/sw/lib/libexec/plasma-changeicons WhiteSur 2>/dev/null \
  || kwriteconfig6 --file kdeglobals --group Icons --key Theme WhiteSur

# Estilo de apps via Kvantum
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
mkdir -p ~/.config/Kvantum
printf '[General]\ntheme=WhiteSur\n' > ~/.config/Kvantum/kvantum.kvconfig

# Decoração de janela + botões à esquerda (fechar, minimizar, maximizar)
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__WhiteSur
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft XIA
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""

# Fonte Inter (parecida com a SF Pro)
kwriteconfig6 --file kdeglobals --group General --key font "Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file kdeglobals --group WM --key activeFont "Inter,10,-1,5,600,0,0,0,0,0,0,0,0,0,0,1"

# qdbus no NixOS (qttools) não tem sufixo 6
QDBUS=$(command -v qdbus6 || command -v qdbus)

# Painéis: barra superior + dock inferior centralizado
"$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
// preserva os lançadores atuais do gerenciador de tarefas
var launchers = "";
panels().forEach(function(p){
  p.widgets().forEach(function(w){
    if (w.type == "org.kde.plasma.icontasks" || w.type == "org.kde.plasma.taskmanager") {
      w.currentConfigGroup = ["General"];
      var l = w.readConfig("launchers", "");
      if (l) launchers = l;
    }
  });
});
panels().forEach(function(p){ p.remove(); });

var top = new Panel;
top.location = "top";
top.height = 28;
top.addWidget("org.kde.plasma.kickoff");
top.addWidget("org.kde.plasma.appmenu");
top.addWidget("org.kde.plasma.panelspacer");
top.addWidget("org.kde.plasma.systemtray");
var clock = top.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);

var dock = new Panel;
dock.location = "bottom";
dock.height = 56;
dock.alignment = "center";
dock.lengthMode = "fit";
dock.floating = true;
dock.hiding = "dodgewindows";
var tm = dock.addWidget("org.kde.plasma.icontasks");
tm.currentConfigGroup = ["General"];
tm.writeConfig("launchers", launchers || "preferred://filemanager,preferred://browser,applications:org.kde.konsole.desktop,applications:systemsettings.desktop");
dock.addWidget("org.kde.plasma.trash");
'

"$QDBUS" org.kde.KWin /KWin reconfigure
echo "Pronto! Faça logout/login para ver tudo aplicado."
