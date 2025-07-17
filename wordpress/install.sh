#!/bin/bash

# 設定來源與目的地路徑
SOURCE_COMPOSE="./compose.yaml"
DEST_DIR="./docker"
DEST_COMPOSE="$DEST_DIR/compose.yaml"

# 檢查來源檔案是否存在
if [ ! -f "$SOURCE_COMPOSE" ]; then
  echo "找不到 compose.yaml 檔案，請確認路徑是否正確。"
  exit 1
fi

# 建立目標資料夾
mkdir -p "$DEST_DIR"

# 檢查是否已有運行中的容器，若有則停止並清理
if [ -f "$DEST_COMPOSE" ]; then
  echo "偵測到已存在的 WordPress 安裝，正在清理..."
  cd "$DEST_DIR" || exit
  docker-compose down -v
  cd ..
fi

# 複製 docker-compose.yml 到 docker 資料夾
cp "$SOURCE_COMPOSE" "$DEST_COMPOSE"
echo "已複製 compose.yaml 到 $DEST_COMPOSE"

# 向使用者詢問 MySQL 密碼
read -s -p "請輸入 MySQL 用戶密碼： " MYSQL_USER_PASS
echo

# 使用 sed 替換 compose.yaml 中的密碼佔位符
# 假設在 YAML 中使用 wppassword 作為預設密碼
sed -i "s/wppassword/$MYSQL_USER_PASS/g" "$DEST_COMPOSE"
echo "已更新 MySQL 密碼設定"

# 進入 docker 資料夾並執行 compose
cd "$DEST_DIR" || exit

echo "正在啟動 WordPress 服務..."
docker-compose up -d

# 檢查容器是否成功啟動
if [ $? -eq 0 ]; then
  echo "WordPress 安裝完成！"
  echo "請打開瀏覽器訪問 http://localhost:8080 開始設定 WordPress"
  echo ""
  echo "MySQL 連線資訊："
  echo "- 資料庫主機：db"
  echo "- 資料庫名稱：wordpress"
  echo "- 使用者名稱：wpuser"
  echo "- 密碼：(您剛才輸入的密碼)"
else
  echo "啟動失敗，請檢查錯誤訊息"
  exit 1
fi