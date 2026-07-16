#!/bin/bash
# Скрипт для запуска GNOME Calendar с правильными настройками CSD кнопок
export GTK_THEME=Adwaita
/usr/bin/gnome-calendar "$@"
