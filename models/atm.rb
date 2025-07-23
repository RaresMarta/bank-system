require_relative '../db/db'

class Atm < Sequel::Model
  one_to_many :transactions
end
