require_relative '../models/transaction'

# Manages database access for Transaction records.
class TransactionRepository
  def for_account(account_id)
    Transaction.where(bank_account_id: account_id).order(Sequel.desc(:created_at))
  end

  def withdrawn_since(account_id, time)
    Transaction
      .where(bank_account_id: account_id, type: 'withdrawal')
      .where{ created_at >= time }
      .sum(:amount) || 0.0
  end

  def create(account_id:, amount:, type:)
    Transaction.create(
      bank_account_id: account_id,
      amount: amount,
      type: type
    )
  end
end
