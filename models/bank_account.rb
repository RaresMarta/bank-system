require_relative '../db/db'

# Represents a bank account data object.
# Business logic is handled by the service layer.
class BankAccount < Sequel::Model
  one_to_many :transactions
end
