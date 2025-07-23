class BankAccountService
  DAILY_WITHDRAWAL_LIMIT = 5000.0

  def initialize(account_repo)
    @account_repo = account_repo
  end

  def get_all_accounts
    @account_repo.all
  end

  def get_account(id)
    account = @account_repo.find(id)
    account ? { account: account } : { error: "Account not found." }
  end

  def create_account(name:, job:, email:, address:)
    @account_repo.create(name: name, job: job, email: email, address: address)
  rescue Sequel::UniqueConstraintViolation
    return { error: "An account with that email already exists." }
  end

  def update_balance(account_id, new_balance)
    @account_repo.update_balance(account_id, new_balance)
  end

  def can_withdraw?(account, amount, withdrawn_today)
    return { error: "Withdrawal amount must be positive." } unless amount > 0
    return { error: "Insufficient funds. Current balance is $#{account.balance}." } if account.balance < amount
    if (withdrawn_today + amount) > DAILY_WITHDRAWAL_LIMIT
      return { error: "Daily withdrawal limit of $#{DAILY_WITHDRAWAL_LIMIT} exceeded. You have withdrawn $#{withdrawn_today} today." }
    end
    { ok: true }
  end
end
