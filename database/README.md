# TOEIC MySQL Database

This directory contains MySQL database scripts for the TOEIC application.

## Database Structure

### Tables
- `words` - 單字表格 (Words table)
- `sentences` - 例句表格 (Sentences table, related to words)
- `users` - 使用者表格 (Users table)
- `registrations` - 註冊表格 (Registration table)

## Setup Instructions

1. Create database: `mysql -u root -p < 01_create_database.sql`
2. Create tables: `mysql -u root -p toeic_db < 02_create_tables.sql`
3. Insert initial data: `mysql -u root -p toeic_db < 03_insert_data.sql`

## Files
- `01_create_database.sql` - Database creation
- `02_create_tables.sql` - Table structure creation
- `03_insert_data.sql` - Initial data insertion
- `init_database.sql` - Complete database initialization script