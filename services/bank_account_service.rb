# Implements the business logic for managing bank accounts.
# It coordinates with the TransactionService for balance changes.
class BankAccountService
  DAILY_WITHDRAWAL_LIMIT = 5000.0

  def initialize(account_repo, transaction_service)
    @account_repo = account_repo
    @transaction_service = transaction_service
  end

  def create_account(name:, job:, email:, address:)
    @account_repo.create(name: name, job: job, email: email, address: address)
  rescue Sequel::UniqueConstraintViolation
    return { error: "An account with that email already exists." }
  end

  def deposit(account_id, amount)
    return { error: "Deposit amount must be positive." } unless amount > 0

    account = @account_repo.find(account_id)
    return { error: "Account not found." } unless account

    DB.transaction do
      new_balance = account.balance + amount
      @account_repo.update_balance(account.id, new_balance)
      @transaction_service.create_transaction(account_id: account.id, amount: amount, type: 'deposit')
      { new_balance: new_balance }
    end
  end

  def withdraw(account_id, amount)
    return { error: "Withdrawal amount must be positive." } unless amount > 0

    account = @account_repo.find(account_id)
    return { error: "Account not found." } unless account

    if account.balance < amount
      return { error: "Insufficient funds. Current balance is $#{account.balance}." }
    end

    withdrawn_today = @transaction_service.get_withdrawn_today(account.id)
    if (withdrawn_today + amount) > DAILY_WITHDRAWAL_LIMIT
      return { error: "Daily withdrawal limit of $#{DAILY_WITHDRAWAL_LIMIT} exceeded. You have withdrawn $#{withdrawn_today} today." }
    end

    DB.transaction do
      new_balance = account.balance - amount
      @account_repo.update_balance(account.id, new_balance)
      @transaction_service.create_transaction(account_id: account.id, amount: amount, type: 'withdrawal')
      { new_balance: new_balance }
    end
  end

  def find_account(id)
    account = @account_repo.find(id)
    account ? { account: account } : { error: "Account not found." }
  end

  def get_transactions(account_id)
    transactions = @transaction_service.get_transactions_for_account(account_id)
    transactions ? { transactions: transactions } : { error: "Account not found." }
  end
end
