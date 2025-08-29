#!/bin/bash

# TOEIC MySQL 資料庫測試腳本
# TOEIC MySQL Database Test Script

# 此腳本使用 Docker 建立臨時 MySQL 容器來測試 SQL 腳本

set -e

# 設定變數
MYSQL_ROOT_PASSWORD="testpassword123"
CONTAINER_NAME="toeic-mysql-test"
MYSQL_PORT="3307"
DB_NAME="toeic_db"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 顏色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 檢查 Docker 是否可用
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安裝或不可用"
        print_info "請安裝 Docker 或手動測試 SQL 腳本"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker 未執行"
        print_info "請啟動 Docker 服務"
        exit 1
    fi
    
    print_success "Docker 檢查通過"
}

# 啟動測試 MySQL 容器
start_mysql_container() {
    print_info "啟動 MySQL 測試容器..."
    
    # 停止並移除舊容器（如果存在）
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    
    # 啟動新容器
    docker run -d \
        --name "$CONTAINER_NAME" \
        -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
        -p "$MYSQL_PORT:3306" \
        mysql:8.0 \
        --character-set-server=utf8mb4 \
        --collation-server=utf8mb4_unicode_ci
    
    print_info "等待 MySQL 容器啟動..."
    
    # 等待 MySQL 準備就緒
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec "$CONTAINER_NAME" mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" &> /dev/null; then
            print_success "MySQL 容器已準備就緒"
            return 0
        fi
        
        print_info "等待 MySQL 準備就緒... ($attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    print_error "MySQL 容器啟動超時"
    return 1
}

# 執行 SQL 腳本測試
test_sql_scripts() {
    print_info "測試 SQL 腳本..."
    
    # 測試完整初始化腳本
    print_info "1. 測試完整初始化腳本..."
    if docker exec -i "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" < "$SCRIPT_DIR/init_database.sql"; then
        print_success "✅ 完整初始化腳本測試通過"
    else
        print_error "❌ 完整初始化腳本測試失敗"
        return 1
    fi
    
    # 驗證資料表建立
    print_info "2. 驗證資料表建立..."
    local tables_count=$(docker exec "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" | tail -n +2 | wc -l)
    if [ "$tables_count" -ge 5 ]; then
        print_success "✅ 資料表建立正確 ($tables_count 個資料表)"
    else
        print_error "❌ 資料表建立不完整 (只有 $tables_count 個資料表)"
        return 1
    fi
    
    # 驗證資料插入
    print_info "3. 驗證資料插入..."
    local words_count=$(docker exec "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "SELECT COUNT(*) FROM words;" | tail -n +2)
    local sentences_count=$(docker exec "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "SELECT COUNT(*) FROM sentences;" | tail -n +2)
    local users_count=$(docker exec "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "SELECT COUNT(*) FROM users;" | tail -n +2)
    
    if [ "$words_count" -gt 0 ] && [ "$sentences_count" -gt 0 ] && [ "$users_count" -gt 0 ]; then
        print_success "✅ 資料插入正確"
        print_info "   - 單字: $words_count"
        print_info "   - 例句: $sentences_count"
        print_info "   - 使用者: $users_count"
    else
        print_error "❌ 資料插入失敗"
        return 1
    fi
    
    # 測試查詢腳本
    print_info "4. 測試範例查詢..."
    if docker exec -i "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" < "$SCRIPT_DIR/sample_queries.sql" > /dev/null; then
        print_success "✅ 範例查詢測試通過"
    else
        print_error "❌ 範例查詢測試失敗"
        return 1
    fi
}

# 測試分步驟腳本
test_step_by_step() {
    print_info "測試分步驟腳本..."
    
    # 重置容器
    docker exec "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $DB_NAME;"
    
    # 步驟 1: 建立資料庫
    print_info "1. 測試建立資料庫..."
    if docker exec -i "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" < "$SCRIPT_DIR/01_create_database.sql"; then
        print_success "✅ 資料庫建立腳本通過"
    else
        print_error "❌ 資料庫建立腳本失敗"
        return 1
    fi
    
    # 步驟 2: 建立資料表
    print_info "2. 測試建立資料表..."
    if docker exec -i "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" < "$SCRIPT_DIR/02_create_tables.sql"; then
        print_success "✅ 資料表建立腳本通過"
    else
        print_error "❌ 資料表建立腳本失敗"
        return 1
    fi
    
    # 步驟 3: 插入資料
    print_info "3. 測試插入資料..."
    if docker exec -i "$CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" < "$SCRIPT_DIR/03_insert_data.sql"; then
        print_success "✅ 資料插入腳本通過"
    else
        print_error "❌ 資料插入腳本失敗"
        return 1
    fi
}

# 清理測試環境
cleanup() {
    print_info "清理測試環境..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    print_success "測試環境清理完成"
}

# 顯示使用說明
show_usage() {
    echo "使用方法: $0 [選項]"
    echo ""
    echo "選項:"
    echo "  --no-cleanup      測試完成後不清理容器"
    echo "  --step-by-step    額外測試分步驟腳本"
    echo "  -h, --help        顯示此說明"
    echo ""
    echo "此腳本會:"
    echo "1. 啟動 MySQL Docker 容器"
    echo "2. 測試所有 SQL 腳本"
    echo "3. 驗證資料庫結構和資料"
    echo "4. 清理測試環境"
}

# 主函數
main() {
    local no_cleanup=false
    local test_step_by_step=false
    
    # 解析參數
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-cleanup)
                no_cleanup=true
                shift
                ;;
            --step-by-step)
                test_step_by_step=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "未知參數: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_info "=== TOEIC MySQL 資料庫測試程式 ==="
    
    # 設定清理陷阱
    if [ "$no_cleanup" = false ]; then
        trap cleanup EXIT
    fi
    
    # 執行測試
    check_docker
    start_mysql_container
    test_sql_scripts
    
    if [ "$test_step_by_step" = true ]; then
        test_step_by_step
    fi
    
    print_success "🎉 所有測試通過！SQL 腳本運作正常。"
    
    if [ "$no_cleanup" = true ]; then
        print_info "測試容器保留中，手動清理請執行:"
        print_info "docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
        print_info "容器連接資訊:"
        print_info "  主機: localhost"
        print_info "  埠號: $MYSQL_PORT"
        print_info "  使用者: root"
        print_info "  密碼: $MYSQL_ROOT_PASSWORD"
        print_info "  資料庫: $DB_NAME"
    fi
}

# 執行主函數
main "$@"