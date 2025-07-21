require_relative 'db'

module Schema
  def self.create
    DB.create_table?(:bank_accounts) do
      primary_key :id
      String :name, null: false
      String :job
      String :email, null: false, unique: true
      String :address
      Float :balance, default: 0.0
    end

    DB.create_table?(:transactions) do
      primary_key :id
      foreign_key :bank_account_id, :bank_accounts, null: false, on_delete: :cascade
      Float :amount, null: false
      String :type, null: false # 'deposit' or 'withdrawal'
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    puts "Database tables created successfully."
  end
end
