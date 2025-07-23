require_relative '../db/db'

class Transaction < Sequel::Model
  many_to_one :bank_account
end
