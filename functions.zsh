# Dynamically loading all functions in the "functions" folder
for file in "functions/*"; do
    if [ -f "$file" ]; then
        source "$file"
    fi
done
