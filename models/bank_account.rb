require_relative '../db/db'

class BankAccount < Sequel::Model
  one_to_many :transactions

  def to_s
    "ID: #{id} | Name: #{name} | Balance: $#{'%.2f' % balance} | Created: #{created_at.strftime('%Y-%m-%d %H:%M')}"
  end
end
