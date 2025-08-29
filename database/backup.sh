#!/bin/bash

# TOEIC MySQL 資料庫備份與還原腳本
# TOEIC MySQL Database Backup and Restore Script

set -e

# 設定變數
DB_NAME="toeic_db"
DB_USER="root"
BACKUP_DIR="./backups"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 顏色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 輔助函數
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 建立備份目錄
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_info "建立備份目錄: $BACKUP_DIR"
    fi
}

# 備份資料庫
backup_database() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/toeic_db_backup_$timestamp.sql"
    
    print_info "開始備份資料庫..."
    print_info "備份檔案: $backup_file"
    
    if mysqldump -u "$DB_USER" -p --single-transaction --routines --triggers "$DB_NAME" > "$backup_file"; then
        print_success "資料庫備份完成: $backup_file"
        
        # 壓縮備份檔案
        if command -v gzip &> /dev/null; then
            gzip "$backup_file"
            print_success "備份檔案已壓縮: $backup_file.gz"
        fi
        
        # 顯示備份檔案大小
        if [ -f "$backup_file.gz" ]; then
            local size=$(du -h "$backup_file.gz" | cut -f1)
            print_info "備份檔案大小: $size"
        else
            local size=$(du -h "$backup_file" | cut -f1)
            print_info "備份檔案大小: $size"
        fi
    else
        print_error "資料庫備份失敗！"
        return 1
    fi
}

# 列出備份檔案
list_backups() {
    print_info "可用的備份檔案:"
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        ls -la "$BACKUP_DIR"/toeic_db_backup_*.sql* | while read line; do
            echo "  $line"
        done
    else
        print_warning "沒有找到備份檔案"
    fi
}

# 還原資料庫
restore_database() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        print_error "請指定備份檔案"
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "備份檔案不存在: $backup_file"
        return 1
    fi
    
    print_warning "⚠️  這將覆蓋現有的資料庫資料！"
    read -p "確定要繼續嗎？ (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_info "開始還原資料庫..."
        
        # 檢查檔案是否為壓縮檔
        if [[ "$backup_file" == *.gz ]]; then
            if gunzip -c "$backup_file" | mysql -u "$DB_USER" -p "$DB_NAME"; then
                print_success "資料庫還原完成！"
            else
                print_error "資料庫還原失敗！"
                return 1
            fi
        else
            if mysql -u "$DB_USER" -p "$DB_NAME" < "$backup_file"; then
                print_success "資料庫還原完成！"
            else
                print_error "資料庫還原失敗！"
                return 1
            fi
        fi
    else
        print_info "還原操作已取消"
    fi
}

# 清理舊備份
cleanup_old_backups() {
    local days=${1:-30}  # 預設保留30天
    
    print_info "清理 $days 天前的備份檔案..."
    
    if [ -d "$BACKUP_DIR" ]; then
        find "$BACKUP_DIR" -name "toeic_db_backup_*.sql*" -type f -mtime +$days -delete
        print_success "舊備份檔案清理完成"
    else
        print_warning "備份目錄不存在"
    fi
}

# 資料庫狀態檢查
check_database_status() {
    print_info "檢查資料庫狀態..."
    
    if mysql -u "$DB_USER" -p "$DB_NAME" -e "
        SELECT 
            'Tables' as Type, COUNT(*) as Count 
        FROM information_schema.tables 
        WHERE table_schema = '$DB_NAME'
        UNION ALL
        SELECT 'Words', COUNT(*) FROM words
        UNION ALL
        SELECT 'Sentences', COUNT(*) FROM sentences
        UNION ALL
        SELECT 'Users', COUNT(*) FROM users
        UNION ALL
        SELECT 'Registrations', COUNT(*) FROM registrations
        UNION ALL
        SELECT 'User Progress', COUNT(*) FROM user_progress;
    " 2>/dev/null; then
        print_success "資料庫狀態檢查完成"
    else
        print_error "無法連接到資料庫"
        return 1
    fi
}

# 自動備份設定
setup_auto_backup() {
    local cron_file="/tmp/toeic_backup_cron"
    local script_path="$SCRIPT_DIR/backup.sh"
    
    print_info "設定自動備份..."
    
    # 建立 cron 工作檔案
    cat > "$cron_file" << EOF
# TOEIC 資料庫每日備份 (每天凌晨 2:00)
0 2 * * * $script_path backup >/dev/null 2>&1

# TOEIC 資料庫每週清理 (每週日凌晨 3:00)
0 3 * * 0 $script_path cleanup >/dev/null 2>&1
EOF
    
    # 安裝 cron 工作
    if crontab "$cron_file" 2>/dev/null; then
        print_success "自動備份設定完成"
        print_info "每日 02:00 自動備份"
        print_info "每週日 03:00 清理舊備份"
        rm "$cron_file"
    else
        print_error "自動備份設定失敗"
        print_info "請手動設定 cron 工作:"
        cat "$cron_file"
        rm "$cron_file"
    fi
}

# 顯示使用說明
show_usage() {
    echo "使用方法: $0 <命令> [選項]"
    echo ""
    echo "命令:"
    echo "  backup              備份資料庫"
    echo "  restore <file>      還原資料庫"
    echo "  list               列出備份檔案"
    echo "  status             檢查資料庫狀態"
    echo "  cleanup [days]     清理舊備份 (預設 30 天)"
    echo "  auto-setup         設定自動備份"
    echo ""
    echo "選項:"
    echo "  -u, --user USER    MySQL 使用者名稱 [預設: root]"
    echo "  -d, --dir DIR      備份目錄 [預設: ./backups]"
    echo "  -h, --help         顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 backup                           # 備份資料庫"
    echo "  $0 restore backups/backup.sql.gz    # 還原資料庫"
    echo "  $0 cleanup 7                        # 清理 7 天前的備份"
}

# 主函數
main() {
    local command=""
    
    # 解析命令列參數
    while [[ $# -gt 0 ]]; do
        case $1 in
            backup|restore|list|status|cleanup|auto-setup)
                command="$1"
                shift
                ;;
            -u|--user)
                DB_USER="$2"
                shift 2
                ;;
            -d|--dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                if [ -z "$command" ]; then
                    print_error "未知命令: $1"
                    show_usage
                    exit 1
                fi
                break
                ;;
        esac
    done
    
    if [ -z "$command" ]; then
        print_error "請指定命令"
        show_usage
        exit 1
    fi
    
    case $command in
        backup)
            create_backup_dir
            backup_database
            ;;
        restore)
            if [ $# -gt 0 ]; then
                restore_database "$1"
            else
                print_error "請指定備份檔案"
                exit 1
            fi
            ;;
        list)
            list_backups
            ;;
        status)
            check_database_status
            ;;
        cleanup)
            local days=${1:-30}
            cleanup_old_backups "$days"
            ;;
        auto-setup)
            setup_auto_backup
            ;;
        *)
            print_error "未知命令: $command"
            show_usage
            exit 1
            ;;
    esac
}

# 執行主函數
main "$@"