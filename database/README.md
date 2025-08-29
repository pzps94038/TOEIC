# TOEIC MySQL Database

This directory contains MySQL database scripts for the TOEIC application migration from static data to MySQL database.

## Database Structure

### Core Tables (核心資料表)
- `words` - 單字表格 (Words table) - Stores TOEIC vocabulary
- `sentences` - 例句表格 (Sentences table) - Example sentences related to words
- `users` - 使用者表格 (Users table) - User accounts and profiles

## Quick Setup

### Option 1: One-command setup (推薦)
```bash
# Complete database initialization
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

### Documentation
- `MIGRATION_GUIDE.md` - Detailed migration guide from static data to MySQL
- `README.md` - This file



## Database Schema

### Key Relationships
- `sentences.word_id` → `words.id` (One-to-Many)

### Sample Data
The initialization includes:
- 12 TOEIC words from the original wordData
- Corresponding example sentences
- 2 demo users (admin, demo_user)

## Next Steps

1. **Application Integration**: Update API endpoints to use database queries
2. **User Authentication**: Implement login/registration system
3. **Administration**: Create admin interface for content management

For detailed migration instructions, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).