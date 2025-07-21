# Handles user interaction for the CLI.
class CliController
  def initialize(account_service, transaction_service)
    @account_service = account_service
    @transaction_service = transaction_service
  end

  def run
    loop do
      print_menu
      choice = prompt("Choose an option")
      case choice
      when '1' then create_account
      when '2' then deposit_money
      when '3' then withdraw_money
      when '4' then list_transactions
      when '5' then break
      else puts "Invalid option. Please try again."
      end
    end
  end

  private

  def print_menu
    puts "\n===== Bank System CLI ====="
    puts "1. Create Account"
    puts "2. Deposit Money"
    puts "3. Withdraw Money"
    puts "4. List Transactions"
    puts "5. Exit"
  end

  def prompt(message)
    print "#{message}: "
    gets.chomp
  end

  def create_account
    puts "\n--- Create New Bank Account ---"
    params = {
      name: prompt("Full Name"),
      job: prompt("Job Title"),
      email: prompt("Email Address"),
      address: prompt("Full Address")
    }
    result = @account_service.create_account(**params)
    if result[:error]
      puts "Error: #{result[:error]}"
    else
      puts "Account created successfully! Your new Account ID is: #{result.id}"
    end
  end

  def deposit_money
    puts "\n--- Deposit Money ---"
    account_id = prompt("Enter Account ID").to_i
    amount = prompt("Amount to deposit").to_f

    result = @account_service.deposit(account_id, amount)
    if result[:error]
      puts "Error: #{result[:error]}"
    else
      puts "Deposit successful. New balance: $#{'%.2f' % result[:new_balance]}"
    end
  end

  def withdraw_money
    puts "\n--- Withdraw Money ---"
    account_id = prompt("Enter Account ID").to_i
    amount = prompt("Amount to withdraw").to_f

    result = @account_service.withdraw(account_id, amount)
    if result[:error]
      puts "Error: #{result[:error]}"
    else
      puts "Withdrawal successful. New balance: $#{'%.2f' % result[:new_balance]}"
    end
  end

  def list_transactions
    puts "\n--- List Transactions ---"
    account_id = prompt("Enter Account ID").to_i

    account_result = @account_service.find_account(account_id)
    return puts "Error: #{account_result[:error]}" if account_result[:error]

    transactions = @transaction_service.get_transactions_for_account(account_id)
    account = account_result[:account]

    puts "\nTransactions for Account ##{account.id} (#{account.name}):"
    if transactions.empty?
      puts "No transactions found."
    else
      transactions.each do |t|
        puts "- #{t.created_at.strftime('%Y-%m-%d %H:%M')} | #{t.type.capitalize.ljust(10)} | $#{'%.2f' % t.amount}"
      end
    end
  end
end
