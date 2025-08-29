# TOEIC MySQL Database

This directory contains MySQL database scripts for the TOEIC application migration from static data to MySQL database.

## Database Structure

### Core Tables (核心資料表)
- `words` - 單字表格 (Words table) - Stores TOEIC vocabulary
- `sentences` - 例句表格 (Sentences table) - Example sentences related to words
- `users` - 使用者表格 (Users table) - User accounts and profiles
- `registrations` - 註冊表格 (Registration table) - User registration and verification
- `user_progress` - 學習進度表格 (Learning progress table) - User learning statistics

## Quick Setup

### Option 1: One-command setup (推薦)
```bash
# Complete database initialization
./install.sh

# Or manually:
mysql -u root -p < init_database.sql
```

### Option 2: Step by step
```bash
# 1. Create database
mysql -u root -p < 01_create_database.sql

# 2. Create tables
mysql -u root -p toeic_db < 02_create_tables.sql

# 3. Insert initial data
mysql -u root -p toeic_db < 03_insert_data.sql
```

## Files Structure

### SQL Scripts
- `01_create_database.sql` - Database creation
- `02_create_tables.sql` - Table structure creation
- `03_insert_data.sql` - Initial data insertion with existing wordData
- `init_database.sql` - Complete database initialization script
- `sample_queries.sql` - Example queries for testing and reference

### Management Scripts
- `install.sh` - Automated installation script with options
- `backup.sh` - Database backup and restore utilities
- `test.sh` - Docker-based testing for SQL scripts validation

### Documentation
- `MIGRATION_GUIDE.md` - Detailed migration guide from static data to MySQL
- `README.md` - This file

## Testing

Run automated tests using Docker:
```bash
./test.sh                    # Basic testing
./test.sh --step-by-step     # Test individual scripts
./test.sh --no-cleanup       # Keep test container for inspection
```

## Backup and Maintenance

```bash
./backup.sh backup           # Create database backup
./backup.sh restore <file>   # Restore from backup
./backup.sh list            # List available backups
./backup.sh auto-setup      # Setup automated daily backups
```

## Database Schema

### Key Relationships
- `sentences.word_id` → `words.id` (One-to-Many)
- `user_progress.user_id` → `users.id` (Many-to-One)
- `user_progress.word_id` → `words.id` (Many-to-One)
- `registrations.user_id` → `users.id` (One-to-One, optional)

### Sample Data
The initialization includes:
- 12 TOEIC words from the original wordData
- Corresponding example sentences
- 2 demo users (admin, demo_user)
- Sample learning progress records

## Next Steps

1. **Application Integration**: Update API endpoints to use database queries
2. **User Authentication**: Implement login/registration system
3. **Progress Tracking**: Add learning progress features
4. **Administration**: Create admin interface for content management

For detailed migration instructions, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).