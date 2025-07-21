# main.rb
require_relative 'lib/bank_account'
require_relative 'lib/transaction'

# Helper to prompt user for input.
def prompt(message)
  print "#{message}: "
  gets.chomp
end

# Find an account or print an error.
def find_account
  id = prompt("Enter Account ID").to_i
  account = BankAccount[id]
  unless account
    puts "Error: Account not found."
    return nil
  end
  account
end

# --- CLI Actions ---

def create_account
  puts "\n--- Create New Bank Account ---"
  name = prompt("Full Name")
  job = prompt("Job Title")
  email = prompt("Email Address")
  address = prompt("Full Address")

  begin
    account = BankAccount.create(name: name, job: job, email: email, address: address)
    puts "Account created successfully! Your new Account ID is: #{account.id}"
  rescue Sequel::UniqueConstraintViolation
    puts "Error: An account with that email already exists."
  end
end

def deposit_money
  puts "\n--- Deposit Money ---"
  account = find_account
  return unless account

  amount = prompt("Amount to deposit").to_f
  if amount <= 0
    puts "Error: Please enter a positive amount."
    return
  end

  if account.deposit(amount)
    puts "Deposit successful. New balance: $#{account.balance}"
  end
end

def withdraw_money
  puts "\n--- Withdraw Money ---"
  account = find_account
  return unless account

  amount = prompt("Amount to withdraw").to_f
  if amount <= 0
    puts "Error: Please enter a positive amount."
    return
  end

  if account.withdraw(amount)
    puts "Withdrawal successful. New balance: $#{account.balance.to_f}"
  end
end

def list_transactions
  puts "\n--- List Transactions ---"
  account = find_account
  return unless account

  puts "\nTransactions for Account ##{account.id} (#{account.name}):"
  transactions = account.transactions.sort_by(&:created_at).reverse

  if transactions.empty?
    puts "No transactions found."
  else
    transactions.each do |t|
      puts "- #{t.created_at.strftime('%Y-%m-%d %H:%M')} | #{t.type.capitalize.ljust(10)} | $#{'%.2f' % t.amount}"
    end
  end
end

# --- Main Application Loop ---

def main_menu
  loop do
    puts "\n===== Bank System CLI ====="
    puts "1. Create Account"
    puts "2. Deposit Money"
    puts "3. Withdraw Money"
    puts "4. List Transactions"
    puts "5. Exit"
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

# Run the application
if __FILE__ == $0
  main_menu
end
