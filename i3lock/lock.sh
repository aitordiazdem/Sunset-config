#!/bin/bash

WALLPAPER="$HOME/.config/wallpapers/anochecer.png"

# Resolucion total del escritorio
RESOLUTION=$(xdpyinfo | awk '/dimensions:/{print $2; exit}')

# Crear directorio temporal
TMP_DIR=$(mktemp -d) || exit 1
OUTPUT="$TMP_DIR/lockscreen.png"

# Restaurar configuracion al desbloquear
cleanup() {
    xset -dpms
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# Activar apagado de monitores tras 5 minutos
xset +dpms
xset dpms 0 0 300
xset dpms force on
xset s reset

# Crear imagen del tamaño total del escritorio
convert -size "$RESOLUTION" xc:black "$OUTPUT" || {
    i3lock --nofork -c 000000
    exit
}

# Detectar los monitores activos
while read -r MONITOR; do

    if [[ "$MONITOR" =~ ([0-9]+)x([0-9]+)([+-][0-9]+)([+-][0-9]+) ]]; then

        WIDTH="${BASH_REMATCH[1]}"
        HEIGHT="${BASH_REMATCH[2]}"
        X="${BASH_REMATCH[3]}"
        Y="${BASH_REMATCH[4]}"

        # Ajustar el fondo a cada monitor
        convert "$WALLPAPER" \
            -resize "${WIDTH}x${HEIGHT}^" \
            -gravity center \
            -extent "${WIDTH}x${HEIGHT}" \
            "$TMP_DIR/monitor.png" || continue

        # Colocar la imagen en su posicion
        convert "$OUTPUT" "$TMP_DIR/monitor.png" \
            -geometry "${X}${Y}" \
            -composite "$OUTPUT"

    fi

done < <(xrandr --query | grep ' connected ')

# Bloquear la pantalla
i3lock --nofork -i "$OUTPUT"