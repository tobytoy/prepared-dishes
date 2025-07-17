#!/bin/bash

# 定義選單選項
options=(
    "Run WordPress install.sh"
    "Run Odoo install.sh"
    "Exit"
)

# 顯示選單
echo "Please select an option:"
select choice in "${options[@]}"; do
    case $choice in
        "Run WordPress install.sh")
            if [ -f ./wordpress/install.sh ]; then
                echo "Switching to WordPress directory and executing install.sh..."
                cd ./wordpress || { echo "Error: Cannot access wordpress directory!"; exit 1; }
                bash ./install.sh
                cd - >/dev/null # 回到原目錄
            else
                echo "Error: wordpress/install.sh not found!"
            fi
            break
            ;;
        "Run Odoo install.sh")
            if [ -f ./odoo/install.sh ]; then
                echo "Switching to Odoo directory and executing install.sh..."
                cd ./odoo || { echo "Error: Cannot access odoo directory!"; exit 1; }
                bash ./install.sh
                cd - >/dev/null # 回到原目錄
            else
                echo "Error: odoo/install.sh not found!"
            fi
            break
            ;;
        "Exit")
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac
done