require_relative '../models/bank_account'

class BankAccountRepository
  def all
    BankAccount.order(:id).all
  end

  def find(id)
    BankAccount[id]
  end

  def create(name:, job:, email:, address:)
    BankAccount.create(name: name, job: job, email: email, address: address)
  end

  def update_balance(account_id, new_balance)
    BankAccount.with_pk!(account_id).update(balance: new_balance)
  end

  def update_field(account_id, field, value)
    BankAccount.with_pk!(account_id).update(field.to_sym => value)
  end

  def find_by_email(email)
    BankAccount.where(email: email).first
  end
end
