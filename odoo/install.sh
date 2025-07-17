#!/bin/bash

# 設定來源與目的地路徑
SOURCE_COMPOSE="./compose.yaml"
DEST_DIR="./docker"
DEST_COMPOSE="$DEST_DIR/compose.yaml"
PASSWORD_FILE="$DEST_DIR/odoo_pg_pass"

# 檢查來源檔案是否存在
if [ ! -f "$SOURCE_COMPOSE" ]; then
  echo "找不到 compose.yaml 檔案，請確認路徑是否正確。"
  exit 1
fi

# 複製 compose.yaml 到 docker 資料夾
cp "$SOURCE_COMPOSE" "$DEST_COMPOSE"
echo "已複製 compose.yaml 到 $DEST_COMPOSE"

# 向使用者詢問密碼
read -s -p "請輸入密碼（將儲存到 odoo_pg_pass）： " USER_PASS
echo
echo "$USER_PASS" > "$PASSWORD_FILE"
echo "密碼已儲存到 $PASSWORD_FILE"

# 進入 docker 資料夾並執行 docker-compose
cd "$DEST_DIR" || exit
docker-compose up -d
