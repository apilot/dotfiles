#!/bin/bash

# Завершить текущие экземпляры polybar
# killall -q polybar

# Ожидание полного завершения работы процессов
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Запуск Polybar со стандартным расположением конфигурационного файла в ~/.config/polybar/config
# polybar mybar &
#
# echo "Polybar загрузился..."
#
#
killall -q polybar

# Wait until the processes have been shut down

 # if type "xrandr" > /dev/null; then
 #      for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
 #        MONITOR=$m polybar --reload mainbar-i3 -c ~/.config/polybar/config.ini&
 #      done
 #    else
 #    polybar --reload mainbar-i3 -c ~/.config/polybar/config.ini &
 #    fi
 #
 #
 


 # Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

screens=$(xrandr --listactivemonitors | grep -v "Monitors" | cut -d" " -f6)

if [[ $(xrandr --listactivemonitors | grep -v "Monitors" | cut -d" " -f4 | cut -d"+" -f2- | uniq | wc -l) == 1 ]]; then
  MONITOR=$(polybar --list-monitors | cut -d":" -f1) TRAY_POS=right polybar main &
else
  primary=$(xrandr --query | grep primary | cut -d" " -f1)

  for m in $screens; do
    if [[ $primary == $m ]]; then
        MONITOR=$m TRAY_POS=right polybar mainbar-i3 &
    elif [[ HDMI-0 == $m ]]; then
        MONITOR=$m TRAY_POS=none polybar topright &
    elif [[ DVI-I-2-1 == $m ]]; then
        MONITOR=$m TRAY_POS=none polybar topleft &
    fi
  done
fi
