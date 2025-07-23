class TransactionService
  ALLOWED_TYPES = %w[deposit withdraw transfer_in transfer_out].freeze

  def initialize(transaction_repo)
    @transaction_repo = transaction_repo
  end

  def create_transaction(account_id:, target_id: nil, atm_id: nil, amount:, type:)
    unless ALLOWED_TYPES.include?(type)
      raise ArgumentError, "Invalid transaction type: #{type}"
    end

    @transaction_repo.create(
      account_id: account_id,
      target_id: target_id,
      atm_id: atm_id,
      amount: amount,
      type: type
    )
  end

  def get_transactions_for_account(account_id)
    @transaction_repo.for_account(account_id)
  end

  def get_withdrawn_today(account_id)
    # Start of the 24-hour window
    window_start = Time.now - 24*60*60
    @transaction_repo.withdrawn_since(account_id, window_start)
  end
end
