#!/system/bin/sh

MODDIR="${0%/*}"
[ -f "$MODDIR/apply.sh" ] || { echo "! Ошибка: apply.sh не найден"; exit 1; }

# Вызываем скрипт применения
sh "$MODDIR/apply.sh" "$MODDIR"