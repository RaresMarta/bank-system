class TransactionService
  TRANSACTION_TYPES = %w[deposit withdraw].freeze

  def initialize(transaction_repo)
    @transaction_repo = transaction_repo
  end

  def create_transaction(account_id:, atm_id:, amount:, type:)
    unless TRANSACTION_TYPES.include?(type)
      raise ArgumentError, "Invalid transaction type: #{type}"
    end

    @transaction_repo.create(
      account_id: account_id,
      atm_id: atm_id,
      amount: amount,
      type: type
    )
  end

  def create_transfer(account_id:, target_id:, amount:)
    @transaction_repo.create(
      account_id: account_id,
      target_id: target_id,
      amount: amount,
      type: 'transfer_out'
    )
    @transaction_repo.create(
      account_id: target_id,
      target_id: account_id,
      amount: amount,
      type: 'transfer_in'
    )
  end

  def get_transactions_for_account(account_id)
    @transaction_repo.for_account(account_id)
  end

  def get_withdrawn_today(account_id)
    now = Time.now
    today_start = Time.new(now.year, now.month, now.day)
    @transaction_repo.withdrawn_since(account_id, window_start)
  end
end
