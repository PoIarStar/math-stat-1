#!/bin/bash

# Конфигурация
EXEC_NAME="myapp"            # Имя файла без расширения
LIB_NAME="myapp.lib"         # Имя файла библиотеки
RES_NAME="myapp.res"         # Имя ресурсного файла
TARGET_BIN="/usr/bin/$EXEC_NAME"
TARGET_LIB="/usr/lib/$LIB_NAME"
TARGET_SHARE="/share/polar"
TARGET_RES="$TARGET_SHARE/$RES_NAME"

# Функция для проверки успешности выполнения
check_success() {
    if [ $? -ne 0 ]; then
        echo "Ошибка: $1" >&2
        exit 1
    fi
}

# 1. Проверка существования исходных файлов
echo "Проверка наличия файлов..."
if [ ! -f "$EXEC_NAME" ]; then echo "Файл $EXEC_NAME не найден."; exit 1; fi
if [ ! -f "$LIB_NAME" ]; then echo "Файл $LIB_NAME не найден."; exit 1; fi
if [ ! -f "$RES_NAME" ]; then echo "Файл $RES_NAME не найден."; exit 1; fi
echo "OK."

# 2. Установка исполняемого файла в /usr/bin
echo "Установка исполняемого файла..."
sudo cp "$EXEC_NAME" "$TARGET_BIN"
check_success "Не удалось скопировать $EXEC_NAME в $TARGET_BIN"
# Установка прав: владелец root (обычно), группа users, права 750 (rwxr-x---)
sudo chown root:users "$TARGET_BIN"
sudo chmod 750 "$TARGET_BIN"
check_success "Не удалось установить права на $TARGET_BIN"
echo "OK."

# 3. Установка библиотеки в /usr/lib
echo "Установка библиотеки..."
sudo cp "$LIB_NAME" "$TARGET_LIB"
check_success "Не удалось скопировать $LIB_NAME в $TARGET_LIB"
# Обычные права для библиотек (644)
sudo chmod 644 "$TARGET_LIB"
echo "OK."

# 4. Установка ресурсного файла в /share/
echo "Установка ресурсного файла..."
sudo mkdir -p "$TARGET_SHARE"
check_success "Не удалось создать директорию $TARGET_SHARE"
sudo cp "$RES_NAME" "$TARGET_RES"
check_success "Не удалось скопировать $RES_NAME в $TARGET_RES"
sudo chmod 644 "$TARGET_RES"
echo "OK."

echo "Установка завершена успешно."
exit 0
