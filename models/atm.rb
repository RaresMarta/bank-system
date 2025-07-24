require_relative '../db/db'

class Atm < Sequel::Model
  plugin :validation_helpers
  one_to_many :transactions

  def validate
    super
    validates_unique :location
  end

  def to_s
    "ID: #{id} | Location: #{location} | Balance: $#{balance} | Created: #{created_at.strftime('%Y-%m-%d %H:%M')}"
  end
end
