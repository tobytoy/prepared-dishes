#!/bin/bash
set -e

# 1. 路徑
SOURCE_COMPOSE="./docker-compose.yml"
DEST_DIR="./docker"
DEST_COMPOSE="$DEST_DIR/docker-compose.yml"

# 2. 檢查來源
if [ ! -f "$SOURCE_COMPOSE" ]; then
  echo "找不到 docker-compose.yml 檔案，請確認路徑是否正確。"
  exit 1
fi

# 3. 建立目標資料夾
mkdir -p "$DEST_DIR"

# 4. 清理舊容器
if [ -f "$DEST_COMPOSE" ]; then
  echo "偵測到已存在的 WordPress 安裝，正在清理..."
  cd "$DEST_DIR"
  docker-compose down -v
  docker system prune -f
  cd ..
fi

# 5. 複製 compose 檔
cp "$SOURCE_COMPOSE" "$DEST_COMPOSE"

# 6. 詢問 MySQL 密碼
read -s -p "請輸入 MySQL 用戶密碼： " MYSQL_USER_PASS
echo

# 7. 取代密碼
sed -i.bak "s/wppassword/$MYSQL_USER_PASS/g" "$DEST_COMPOSE"

# 8. 自動產生公開網址並插入 WORDPRESS_CONFIG_EXTRA
#    若不在 Codespaces，可手動填入 URL；腳本會提示。
PUBLIC_URL=""
if [ -n "$CODESPACE_NAME" ] && [ -n "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
  PUBLIC_URL="https://${CODESPACE_NAME}-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
else
  read -p "未偵測到 Codespaces，請手動輸入公開網址 (含 https://)： " PUBLIC_URL
fi

# 把 WORDPRESS_CONFIG_EXTRA 插進 environment 區塊
# 先檢查是否已存在，避免重複
if ! grep -q "WORDPRESS_CONFIG_EXTRA" "$DEST_COMPOSE"; then
  sed -i.bak "/WORDPRESS_DB_NAME:.*/a\\
      WORDPRESS_CONFIG_EXTRA: |\\
        define('WP_HOME','$PUBLIC_URL');\\
        define('WP_SITEURL','$PUBLIC_URL');\\
        \$_SERVER['HTTPS'] = 'on';" "$DEST_COMPOSE"
else
  # 若已存在，直接取代
  sed -i.bak "s|define('WP_HOME'.*|define('WP_HOME','$PUBLIC_URL');|" "$DEST_COMPOSE"
  sed -i.bak "s|define('WP_SITEURL'.*|define('WP_SITEURL','$PUBLIC_URL');|" "$DEST_COMPOSE"
fi

echo "已更新 MySQL 密碼與公開網址 ($PUBLIC_URL)"

# 9. 啟動流程
cd "$DEST_DIR"

echo "正在啟動 MySQL 資料庫..."
docker-compose up -d db

echo "等待 MySQL 資料庫啟動完成..."
sleep 15

max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
  if docker-compose exec -T db mysql -u wpuser -p"$MYSQL_USER_PASS" -e "SELECT 1" wordpress &>/dev/null; then
    echo "MySQL 連線成功！"
    break
  fi
  echo "嘗試 $attempt/$max_attempts: 等待 MySQL 準備就緒..."
  sleep 2
  ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
  echo "MySQL 連線逾時，請檢查設定"
  exit 1
fi

echo "正在啟動 WordPress 服務..."
docker-compose up -d wordpress
sleep 10

if docker-compose ps | grep -q "Up"; then
  echo "WordPress 安裝完成！"
  echo "請打開瀏覽器訪問 $PUBLIC_URL 開始設定 WordPress"
  echo ""
  echo "MySQL 連線資訊："
  echo "- 資料庫主機：db"
  echo "- 資料庫名稱：wordpress"
  echo "- 使用者名稱：wpuser"
  echo "- 密碼：(您剛才輸入的密碼)"
  echo ""
  echo "如果遇到錯誤，請執行以下命令查看詳細日誌："
  echo "cd $DEST_DIR && docker-compose logs"
else
  echo "啟動失敗，請檢查錯誤訊息："
  docker-compose logs
  exit 1
fi

# #!/bin/bash

# # 設定來源與目的地路徑
# SOURCE_COMPOSE="./docker-compose.yml"
# DEST_DIR="./docker"
# DEST_COMPOSE="$DEST_DIR/docker-compose.yml"

# # 檢查來源檔案是否存在
# if [ ! -f "$SOURCE_COMPOSE" ]; then
#   echo "找不到 docker-compose.yml 檔案，請確認路徑是否正確。"
#   exit 1
# fi

# # 建立目標資料夾
# mkdir -p "$DEST_DIR"

# # 檢查是否已有運行中的容器，若有則停止並清理
# if [ -f "$DEST_COMPOSE" ]; then
#   echo "偵測到已存在的 WordPress 安裝，正在清理..."
#   cd "$DEST_DIR" || exit
#   docker-compose down -v
#   docker system prune -f
#   cd ..
# fi

# # 複製 docker-compose.yml 到 docker 資料夾
# cp "$SOURCE_COMPOSE" "$DEST_COMPOSE"
# echo "已複製 docker-compose.yml 到 $DEST_COMPOSE"

# # 向使用者詢問 MySQL 密碼
# read -s -p "請輸入 MySQL 用戶密碼： " MYSQL_USER_PASS
# echo

# # 使用 sed 替換 docker-compose.yml 中的密碼佔位符
# sed -i.bak "s/wppassword/$MYSQL_USER_PASS/g" "$DEST_COMPOSE"
# echo "已更新 MySQL 密碼設定"

# # 進入 docker 資料夾並執行 docker-compose
# cd "$DEST_DIR" || exit

# echo "正在啟動 MySQL 資料庫..."
# docker-compose up -d db

# echo "等待 MySQL 資料庫啟動完成..."
# sleep 15

# # 檢查 MySQL 是否準備就緒
# echo "檢查 MySQL 連線..."
# max_attempts=30
# attempt=1
# while [ $attempt -le $max_attempts ]; do
#   if docker-compose exec -T db mysql -u wpuser -p"$MYSQL_USER_PASS" -e "SELECT 1" wordpress &>/dev/null; then
#     echo "MySQL 連線成功！"
#     break
#   fi
#   echo "嘗試 $attempt/$max_attempts: 等待 MySQL 準備就緒..."
#   sleep 2
#   ((attempt++))
# done

# if [ $attempt -gt $max_attempts ]; then
#   echo "MySQL 連線逾時，請檢查設定"
#   exit 1
# fi

# echo "正在啟動 WordPress 服務..."
# docker-compose up -d wordpress

# echo "等待 WordPress 啟動完成..."
# sleep 10

# # 檢查容器是否成功啟動
# if docker-compose ps | grep -q "Up"; then
#   echo "WordPress 安裝完成！"
#   echo "請打開瀏覽器訪問 http://localhost:8080 開始設定 WordPress"
#   echo ""
#   echo "MySQL 連線資訊："
#   echo "- 資料庫主機：db"
#   echo "- 資料庫名稱：wordpress"
#   echo "- 使用者名稱：wpuser"
#   echo "- 密碼：(您剛才輸入的密碼)"
#   echo ""
#   echo "如果遇到錯誤，請執行以下命令查看詳細日誌："
#   echo "cd $DEST_DIR && docker-compose logs"
# else
#   echo "啟動失敗，請檢查錯誤訊息："
#   docker-compose logs
#   exit 1
# fi