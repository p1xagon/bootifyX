#!/system/bin/sh

# apply.sh [папка_модуля] [путь_к_zip]
MODDIR="${1:-${0%/*}}"
SRC="${2:-/sdcard/BootAnim/bootanimation.zip}"

[ -f "$SRC" ] || { echo "! Файл не найден: $SRC"; exit 1; }
[ -s "$MODDIR/targets.txt" ] || { echo "! targets.txt пуст или отсутствует"; exit 1; }

# Проверка, что это реально bootanimation.zip (с поддержкой busybox)
if command -v unzip >/dev/null 2>&1; then
  unzip -l "$SRC" 2>/dev/null | grep -q "desc.txt" || { echo "! В архиве нет desc.txt - это не bootanimation.zip"; exit 1; }
elif command -v busybox >/dev/null 2>&1; then
  busybox unzip -l "$SRC" 2>/dev/null | grep -q "desc.txt" || { echo "! В архиве нет desc.txt - это не bootanimation.zip"; exit 1; }
fi

# Очищаем старые файлы модуля перед копированием новых
rm -rf "$MODDIR/system" "$MODDIR/product" "$MODDIR/system_ext"

COUNT=0
while read -r T; do
  [ -z "$T" ] && continue
  T=$(echo "$T" | tr -d '\r') # Убираем возможные проблемы с переносом строк (Windows)

  # Правильное монтирование путей для HyperOS
  case "$T" in
    /*) DEST="$MODDIR$T" ;;
    *)  DEST="$MODDIR/system/$T" ;;
  esac
  
  mkdir -p "${DEST%/*}"
  cp -f "$SRC" "$DEST" || { echo "! Не удалось скопировать в $DEST"; exit 1; }
  
  # Выставляем права и контекст SELinux (важно для HyperOS)
  chmod 0644 "$DEST"
  chown 0:0 "$DEST" 2>/dev/null
  chcon u:object_r:system_file:s0 "$DEST" 2>/dev/null
  
  COUNT=$((COUNT + 1))
done < "$MODDIR/targets.txt"

echo "- Готово, файлов заменено: $COUNT"
echo "- Перезагрузи телефон, чтобы увидеть новую анимацию"