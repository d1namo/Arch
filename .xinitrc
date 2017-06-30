# .xinitrc
wal -i "${HOME}/Imágenes/Wallpapers/" -o wal-set

xrdb ~/.Xresources

session=${1:-xfce}

case $session in
    i3|i3wm           ) exec i3;;
    xfce|xfce4        ) exec startxfce4;;
    # No known session, try to run it as command
    *                 ) exec $1;;
esac