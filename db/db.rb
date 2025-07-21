require 'sequel'

DB = Sequel.connect(
  adapter: 'postgres',
  host: 'localhost',
  database: 'bank_system',
  user: 'rares',
  password: ENV['DB_PASSWORD']
)
