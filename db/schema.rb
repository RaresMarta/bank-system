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
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    DB.create_table?(:atms) do
      primary_key :id
      String :location, null: false, unique: true
      Float :balance, default: 10_000
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    DB.create_table?(:transactions) do
      primary_key :id
      foreign_key :bank_account_id, :bank_accounts, null: false, on_delete: :cascade
      foreign_key :target_account_id, :bank_accounts, null: true, on_delete: :set_null
      foreign_key :atm_id, :atms, null: true, on_delete: :set_null
      Float :amount, null: false
      String :type, null: false # 'deposit', 'withdrawal', 'transfer_in', 'transfer_out'
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

  def self.create_dummy_data
    require_relative '../models/bank_account'
    require_relative '../models/atm'

    BankAccount.create(
      name: 'Burebista',
      job: 'King of Dacia',
      email: 'burebista@dacia.ro',
      address: 'Sarmizegetusa Regia',
      balance: 3000.0
    )

    BankAccount.create(
      name: 'Vlad Țepeș',
      job: 'Voivode of Wallachia',
      email: 'vlad.tepes@wallachia.ro',
      address: 'Poenari Fortress',
      balance: 4500.0
    )

    Atm.create(
      location: 'Sighișoara Citadel',
      balance: 6000.0
    )

    Atm.create(
      location: 'Dacian Mountains',
      balance: 9000.0
    )

    puts "Dummy data inserted."
  end
end
