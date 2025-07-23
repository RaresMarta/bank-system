require_relative '../models/transaction'

class TransactionRepository
  def for_account(account_id)
    Transaction.where(bank_account_id: account_id).order(Sequel.desc(:created_at))
  end

  def create(account_id:, target_id:, atm_id:, amount:, type:)
    Transaction.create(
      bank_account_id: account_id,
      target_account_id: target_id,
      atm_id: atm_id,
      amount: amount,
      type: type
    )
  end

  def withdrawn_since(account_id, time)
    Transaction
      .where(bank_account_id: account_id, type: 'withdraw')
      .where{ created_at >= time }
      .sum(:amount) || 0.0
  end
end
