#!/bin/bash

# TOEIC MySQL 資料庫安裝腳本
# TOEIC MySQL Database Installation Script

set -e  # 遇到錯誤時停止執行

# 設定變數
DB_NAME="toeic_db"
DB_USER="root"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 顏色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 輔助函數
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查 MySQL 是否已安裝
check_mysql() {
    print_info "檢查 MySQL 安裝狀態..."
    if ! command -v mysql &> /dev/null; then
        print_error "MySQL 未安裝，請先安裝 MySQL 8.0 或更高版本"
        exit 1
    fi
    
    # 檢查 MySQL 版本
    MYSQL_VERSION=$(mysql --version | awk '{print $5}' | cut -d',' -f1)
    print_info "發現 MySQL 版本: $MYSQL_VERSION"
}

# 測試 MySQL 連接
test_mysql_connection() {
    print_info "測試 MySQL 連接..."
    if mysql -u "$DB_USER" -p -e "SELECT 1;" &> /dev/null; then
        print_success "MySQL 連接成功"
    else
        print_error "MySQL 連接失敗，請檢查使用者名稱和密碼"
        exit 1
    fi
}

# 安裝資料庫
install_database() {
    local method="$1"
    
    case $method in
        "complete")
            print_info "使用完整安裝腳本..."
            mysql -u "$DB_USER" -p < "$SCRIPT_DIR/init_database.sql"
            ;;
        "step")
            print_info "使用分步驟安裝..."
            print_info "1. 建立資料庫..."
            mysql -u "$DB_USER" -p < "$SCRIPT_DIR/01_create_database.sql"
            
            print_info "2. 建立資料表..."
            mysql -u "$DB_USER" -p "$DB_NAME" < "$SCRIPT_DIR/02_create_tables.sql"
            
            print_info "3. 插入初始資料..."
            mysql -u "$DB_USER" -p "$DB_NAME" < "$SCRIPT_DIR/03_insert_data.sql"
            ;;
        *)
            print_error "未知的安裝方法: $method"
            exit 1
            ;;
    esac
}

# 驗證安裝
verify_installation() {
    print_info "驗證資料庫安裝..."
    
    # 檢查資料表
    TABLES=$(mysql -u "$DB_USER" -p "$DB_NAME" -e "SHOW TABLES;" 2>/dev/null | tail -n +2 | wc -l)
    if [ "$TABLES" -ge 5 ]; then
        print_success "資料表建立成功 ($TABLES 個資料表)"
    else
        print_error "資料表建立可能有問題 (只有 $TABLES 個資料表)"
        return 1
    fi
    
    # 檢查資料
    WORDS_COUNT=$(mysql -u "$DB_USER" -p "$DB_NAME" -e "SELECT COUNT(*) FROM words;" 2>/dev/null | tail -n +2)
    SENTENCES_COUNT=$(mysql -u "$DB_USER" -p "$DB_NAME" -e "SELECT COUNT(*) FROM sentences;" 2>/dev/null | tail -n +2)
    USERS_COUNT=$(mysql -u "$DB_USER" -p "$DB_NAME" -e "SELECT COUNT(*) FROM users;" 2>/dev/null | tail -n +2)
    
    print_success "單字數量: $WORDS_COUNT"
    print_success "例句數量: $SENTENCES_COUNT"
    print_success "使用者數量: $USERS_COUNT"
}

# 顯示使用說明
show_usage() {
    echo "使用方法: $0 [選項]"
    echo ""
    echo "選項:"
    echo "  -m, --method METHOD    安裝方法 (complete|step) [預設: complete]"
    echo "  -u, --user USER        MySQL 使用者名稱 [預設: root]"
    echo "  -h, --help            顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0                    # 使用預設設定進行完整安裝"
    echo "  $0 -m step           # 使用分步驟安裝"
    echo "  $0 -u myuser         # 使用指定的 MySQL 使用者"
}

# 主函數
main() {
    local method="complete"
    
    # 解析命令列參數
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--method)
                method="$2"
                shift 2
                ;;
            -u|--user)
                DB_USER="$2"
                shift 2
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
    
    # 驗證安裝方法
    if [[ "$method" != "complete" && "$method" != "step" ]]; then
        print_error "安裝方法必須是 'complete' 或 'step'"
        exit 1
    fi
    
    print_info "=== TOEIC MySQL 資料庫安裝程式 ==="
    print_info "資料庫名稱: $DB_NAME"
    print_info "MySQL 使用者: $DB_USER"
    print_info "安裝方法: $method"
    echo ""
    
    # 執行安裝步驟
    check_mysql
    # test_mysql_connection  # 註解掉因為會要求密碼輸入
    
    print_info "開始安裝資料庫..."
    if install_database "$method"; then
        print_success "資料庫安裝完成！"
        
        print_info "執行安裝驗證..."
        if verify_installation; then
            print_success "✅ 所有檢查通過！TOEIC 資料庫已準備就緒。"
            echo ""
            print_info "下一步："
            print_info "1. 更新應用程式設定以連接到資料庫"
            print_info "2. 修改 API 端點以使用資料庫查詢"
            print_info "3. 測試應用程式功能"
        else
            print_warning "⚠️  安裝驗證發現一些問題，請檢查上述錯誤訊息"
        fi
    else
        print_error "❌ 資料庫安裝失敗！"
        exit 1
    fi
}

# 執行主函數
main "$@"