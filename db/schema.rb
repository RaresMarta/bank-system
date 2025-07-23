require_relative 'db'

module Schema
  def self.create
    DB.create_table?(:bank_accounts) do
      primary_key :id
      String :name, null: false
      String :job, null: true
      String :email, null: false, unique: true
      String :address, null: true
      Float :balance, default: 0.0
    end

    DB.create_table?(:atms) do
      primary_key :id
      String :location, null: false
      Float :balance, default: 10_000
    end

    DB.create_table?(:transactions) do
      primary_key :id
      foreign_key :bank_account_id, :bank_accounts, null: false, on_delete: :cascade
      foreign_key :target_account_id, :bank_accounts, null: true, on_delete: :set_null
      foreign_key :atm_id, :atms, null: true, on_delete: :set_null
      Float :amount, null: false
      String :type, null: false # 'deposit', 'withdrawal', 'transfer'
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    puts "Database tables created successfully."
  end

  def self.drop_all
    DB.drop_table?(:transactions)
    DB.drop_table?(:atms)
    DB.drop_table?(:bank_accounts)
    puts "Database tables dropped."
  end
end
