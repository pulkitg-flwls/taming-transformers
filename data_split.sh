#!/bin/bash

# Root directory containing subfolders
BASE_DIR="./data/vqgan_dataset"  # change as needed

# Output files
TRAIN_FILE="./data/cluster_train.txt"
VAL_FILE="./data/cluster_val.txt"

# Cleanup old output
rm -f "$TRAIN_FILE" "$VAL_FILE"

# If no arguments are passed, use all subfolders
if [ "$#" -eq 0 ]; then
    echo "No subfolders specified. Using all folders in $BASE_DIR"
    readarray -t SELECTED_FOLDERS < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
else
    SELECTED_FOLDERS=("$@")
fi

# Gather image paths
ALL_IMAGES=()
for SUB in "${SELECTED_FOLDERS[@]}"; do
    FOLDER="$BASE_DIR/$SUB"
    if [ -d "$FOLDER" ]; then
        while IFS= read -r -d '' IMG; do
            REL_PATH="${IMG#$BASE_DIR/}"              # removes "images/" from the path
            FINAL_PATH="$BASE_DIR/$REL_PATH"          # adds "images/" back, cleanly
            ALL_IMAGES+=("$FINAL_PATH")
        done < <(find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -print0)
    else
        echo "Warning: Folder '$FOLDER' not found. Skipping."
    fi
done

# Check if any images were found
TOTAL=${#ALL_IMAGES[@]}
if [ "$TOTAL" -eq 0 ]; then
    echo "No images found in specified folders. Exiting."
    exit 1
fi

# Shuffle and split
TRAIN_COUNT=$((TOTAL * 80 / 100))
SHUFFLED=($(shuf -e "${ALL_IMAGES[@]}"))

for i in "${!SHUFFLED[@]}"; do
    if [ "$i" -lt "$TRAIN_COUNT" ]; then
        echo "${SHUFFLED[$i]}" >> "$TRAIN_FILE"
    else
        echo "${SHUFFLED[$i]}" >> "$VAL_FILE"
    fi
done

echo "Done. Total: $TOTAL | Train: $TRAIN_COUNT | Val: $((TOTAL - TRAIN_COUNT))"