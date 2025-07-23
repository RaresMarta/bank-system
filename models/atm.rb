require_relative '../db/db'

class Atm < Sequel::Model
  plugin :validation_helpers
  one_to_many :transactions

  def validate
    super
    validates_unique :location
  end
end
