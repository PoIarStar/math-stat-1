#!/bin/bash

# Определяем дату в формате ГодМесяцДень (например, 20231027)
BACKUP_DATE=$(date +%Y%m%d)
BACKUP_DIR="/var/backups/$BACKUP_DATE"

# Создаем директорию для бэкапов (с sudo, так как /var/backups обычно принадлежит root)
echo "Создание директории $BACKUP_DIR..."
sudo mkdir -p "$BACKUP_DIR"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось создать директорию $BACKUP_DIR." >&2
    exit 1
fi

echo "Поиск файлов в текущем каталоге $(pwd)..."

# Получаем список расширений файлов в текущей директории (игнорируем скрытые и директории)
extensions=$(find . -maxdepth 1 -type f ! -name ".*" -name "*.*" | sed 's/.*\.//' | sort -u)

# Проверяем, найдены ли файлы с расширениями
if [ -z "$extensions" ]; then
    echo "В текущем каталоге не найдено не скрытых файлов с расширениями."
    exit 0
fi

# Переменная для подсчета созданных архивов
archived_count=0

# Проходим по каждому найденному расширению
for ext in $extensions; do
    echo "Обработка расширения: .$ext"
    
    # Находим все файлы с текущим расширением, исключая скрытые и подкаталоги
    file_list=$(find . -maxdepth 1 -type f ! -name ".*" -name "*.$ext")
    
    # Проверяем, что список файлов не пуст
    if [ -n "$file_list" ]; then
        # Имя архива
        archive_name="$ext.tar.gz"
        archive_path="$BACKUP_DIR/$archive_name"
        
        # Создаем архив. Используем tar с опцией --transform чтобы убрать './' из имен файлов в архиве
        # или просто перечисляем файлы без './'. Лучше передать список через xargs или массив.
        # Простой и надежный способ: заархивировать с именами, содержащими ./, это не страшно.
        # Используем sudo для tar, так как конечная папка может принадлежать root.
        echo "  Создание архива $archive_name..."
        
        # Формируем команду tar. Передаем имена файлов, найденные find.
        # Используем массив для безопасной передачи имен с пробелами.
        files_array=()
        while IFS= read -r file; do
            files_array+=("$file")
        done < <(find . -maxdepth 1 -type f ! -name ".*" -name "*.$ext" -printf "%f\n")
        
        # Проверяем, есть ли файлы в массиве
        if [ ${#files_array[@]} -gt 0 ]; then
            # Создаем архив с помощью tar и sudo
            sudo tar -cf "$archive_path" -C . "${files_array[@]}"
            if [ $? -eq 0 ]; then
                echo "  Архив создан: $archive_path"
                ((archived_count++))
            else
                echo "  Ошибка при создании архива для .$ext" >&2
            fi
        fi
    fi
done

echo "Создано архивов: $archived_count в директории $BACKUP_DIR"
exit 0
