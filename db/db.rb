require 'sequel'
require 'dotenv/load'

retries = 10
begin
  DB = Sequel.connect(
    adapter:  'postgres',
    host:     ENV['DB_HOST'],
    database: ENV['DB_NAME'],
    user:     ENV['DB_USER'],
    password: ENV['DB_PASSWORD']
  )
  DB.test_connection
rescue Sequel::DatabaseConnectionError => e
  puts "Waiting for database to be ready... (#{retries} retries left)"
  sleep 2
  retries -= 1
  retry if retries > 0
  raise e
end
