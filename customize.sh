#!/system/bin/sh

# Проверка, что скрипт запущен из менеджера модулей
[ -n "$MODPATH" ] || { echo "! Запускай через KernelSU/Magisk"; exit 1; }

ui_print "- bootifyX (HyperOS Edition)"
ui_print "- Ищу системную загрузочную анимацию..."

: > "$MODPATH/targets.txt"

# Сканируем пути, где HyperOS/MIUI хранит анимации
for d in /system/media /product/media /system_ext/media; do
  for f in "$d"/bootanimation*.zip; do
    [ -f "$f" ] && echo "$f" >> "$MODPATH/targets.txt"
  done
done

[ -s "$MODPATH/targets.txt" ] || abort "! bootanimation.zip на этой прошивке не найден. Модуль не будет работать."

ui_print "- Найдены цели для подмены:"
while read -r T; do
  ui_print "    $T"
done < "$MODPATH/targets.txt"

# Выставляем права на скрипты
set_perm "$MODPATH/apply.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755

# Готовим папку для пользовательских анимаций
mkdir -p /sdcard/BootAnim

if [ -f /sdcard/BootAnim/bootanimation.zip ]; then
  ui_print "- Нашёл /sdcard/BootAnim/bootanimation.zip, применяю..."
  sh "$MODPATH/apply.sh" "$MODPATH" || abort "! Ошибка при применении анимации"
else
  ui_print "- Своей анимации пока нет."
  ui_print "- Положи bootanimation.zip в /sdcard/BootAnim/"
  ui_print "  и нажми Action у модуля, потом перезагрузись."
fi