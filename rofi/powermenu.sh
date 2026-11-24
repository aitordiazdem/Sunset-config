#!/bin/bash

OPTIONS="Apagar\nReiniciar\nSuspender\nBloquear\nCerrar sesion"

SELECTED=$(printf '%b\n' "$OPTIONS" | rofi -dmenu -i -p "Power Menu")

confirmar() {
    [[ $(printf 'No\nSi' | rofi -dmenu -p "Confirmar $1") == "Si" ]]
}

case "$SELECTED" in
    "Apagar")
        confirmar "apagado" && systemctl poweroff
        ;;
    "Reiniciar")
        confirmar "reinicio" && systemctl reboot
        ;;
    "Suspender")
        systemctl suspend
        ;;
    "Bloquear")
        loginctl lock-session "$XDG_SESSION_ID"
        ;;
    "Cerrar sesion")
        confirmar "salida" && i3-msg exit
        ;;
esac
