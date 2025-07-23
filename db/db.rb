require 'sequel'
require 'dotenv/load'

DB = Sequel.connect(
  adapter: 'postgres',
  host: ENV.fetch('DB_HOST', 'localhost'),
  database: ENV['DB_NAME'],
  user: ENV['DB_USER'],
  password: ENV['DB_PASSWORD']
)
