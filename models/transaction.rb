require_relative '../db/db'

class Transaction < Sequel::Model
  many_to_one :bank_account

  def to_s
    "ID #{id} | #{created_at.strftime('%Y-%m-%d %H:%M')} | #{type.capitalize.ljust(10)} | $#{amount}"
  end
end
