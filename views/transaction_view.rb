require_relative "view"

class TransactionView < View
  def list_transactions(account, transactions)
    print_header("Transactions for Account ##{account.id} (#{account.name})")
    if transactions.empty?
      puts "No transactions found."
    else
      transactions.each do |t|
      	puts "- id #{t.id} | #{t.created_at.strftime('%Y-%m-%d %H:%M')} | #{t.type.capitalize.ljust(10)} | $#{'%.2f' % t.amount}"
			end
    end
  end

	def deposit_success(amount, balance)
		print_success("Deposited $#{amount}. New balance: $#{balance}")
	end

	def deposit_failure(error)
		print_error("Failed to deposit: #{error}")
	end

	def withdraw_success(amount, balance)
		print_success("Withdrew $#{amount}. New balance: $#{balance}")
	end

	def withdraw_failure(error)
		print_error("Failed to withdraw: #{error}")
	end

	def transfer_success(amount, from_acc_id, to_acc_id)
		print_success("Transferred $#{amount} successfully. From ##{from_acc_id} to ##{to_acc_id}")
	end

	def transfer_failure(error)
		print_error("Failed to transfer: #{error}")
	end
end
