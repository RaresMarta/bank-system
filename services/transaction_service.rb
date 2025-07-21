# Implements the business logic for managing transactions.
class TransactionService
  def initialize(transaction_repo)
    @transaction_repo = transaction_repo
  end

  def create_transaction(account_id:, amount:, type:)
    @transaction_repo.create(account_id: account_id, amount: amount, type: type)
  end

  def get_transactions_for_account(account_id)
    @transaction_repo.for_account(account_id)
  end

  def get_withdrawn_today(account_id)
    @transaction_repo.withdrawn_since(account_id, Time.now - 24*60*60)
  end
end
