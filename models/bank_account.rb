require_relative '../db/db'

class BankAccount < Sequel::Model
  one_to_many :transactions
end
