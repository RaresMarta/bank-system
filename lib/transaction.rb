require_relative '../db/db'

# Represents a single financial transaction (deposit or withdrawal).
class Transaction < Sequel::Model
  many_to_one :bank_account
end
