import * as mysql from 'mysql2/promise';

/**
 * MySQL 資料庫連接配置
 */
interface DatabaseConfig {
  host: string;
  user: string;
  password: string;
  database: string;
  charset: string;
}

/**
 * 預設資料庫配置
 */
const defaultConfig: DatabaseConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'toeic_db',
  charset: 'utf8mb4'
};

/**
 * 建立資料庫連接
 */
export async function createConnection() {
  try {
    const connection = await mysql.createConnection(defaultConfig);
    return connection;
  } catch (error) {
    console.error('Database connection failed:', error);
    throw new Error('無法連接到資料庫');
  }
}

/**
 * 建立資料庫連接池
 */
export const pool = mysql.createPool({
  ...defaultConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});