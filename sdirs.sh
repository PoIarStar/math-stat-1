#!/usr/bin/bash

OUTPUT_FILE="home_subdirs.csv"

> $OUTPUT_FILE

HOME_DIR="$HOME"

if [ ! -d "$HOME_DIR" ]; then
    echo "Ошибка: Домашний каталог $HOME_DIR не найден." >&2
    exit 1
fi

printf "Подкаталог\tРазмер\n" >> "$OUTPUT_FILE"

for item in "$HOME_DIR"/*/ ; do
    if [ -d "$item" ]; then
        dirname=$(basename "$item")
        size=$(du -sh "$item" | cut -f1)
        printf "$dirname\t$size\n" >> "$OUTPUT_FILE"
    fi
done

exit 0
