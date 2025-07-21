require_relative '../db/db'
require_relative 'transaction'

class BankAccount < Sequel::Model
  one_to_many :transactions

  DAILY_WITHDRAWAL_LIMIT = 5000.0

  def withdraw(amount)
    # Rule 1: Prevent overdraft
    if balance < amount
      puts "Error: Insufficient funds. Current balance is $#{balance}."
      return nil
    end

    # Rule 2: Enforce daily withdrawal limit
    withdrawn_today = transactions_dataset
      .where(type: 'withdrawal', created_at: (Time.now - 24*60*60)..Time.now)
      .sum(:amount) || 0.0

    if (withdrawn_today + amount) > DAILY_WITHDRAWAL_LIMIT
      puts "Error: Daily withdrawal limit of $#{DAILY_WITHDRAWAL_LIMIT} exceeded."
      puts "You have already withdrawn $#{withdrawn_today} in the last 24 hours."
      return nil
    end

    # All checks passed, proceed with withdrawal
    DB.transaction do
      self.balance -= amount
      save
      Transaction.create(
        bank_account_id: id,
        amount: amount,
        type: 'withdrawal'
      )
    end
  end

  # Deposits a specified amount into the account.
  def deposit(amount)
    DB.transaction do
      self.balance += amount
      save
      Transaction.create(
        bank_account_id: id,
        amount: amount,
        type: 'deposit'
      )
    end
  end
end
