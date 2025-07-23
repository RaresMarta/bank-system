class CliController
  def initialize(account_service, transaction_service, atm_service)
    @account_service = account_service
    @transaction_service = transaction_service
    @atm_service = atm_service
  end

  def run
    loop do
      print_menu
      choice = prompt("Choose an option")
      case choice
      when '1' then create_account
      when '2' then list_accounts
      when '3' then deposit_money
      when '4' then withdraw_money
      when '5' then transfer_money
      when '6' then list_transactions
      when '7' then create_atm
      when '8' then break
      else puts "Invalid option. Please try again."
      end
    end
  end

  private

  def print_menu
    puts "\n===== Bank System CLI ====="
    puts "1. Create Account"
    puts "2. List Accounts"
    puts "3. Deposit Money"
    puts "4. Withdraw Money"
    puts "5. Transfer Money"
    puts "6. List Transactions"
    puts "7. Add ATM"
    puts "8. Exit"
  end

  def prompt(message)
    print "#{message}: "
    gets.chomp
  end

  def create_account
    puts "\n--- Create New Bank Account ---"
    params = {
      name:    prompt("Full Name"),
      job:     prompt("Job Title"),
      email:   prompt("Email Address"),
      address: prompt("Full Address")
    }
    result = @account_service.create_account(**params)
    if result[:error]
      puts "Error: #{result[:error]}"
    else
      puts "Account created successfully! Your new Account ID is: #{result.id}"
    end
  end

  def list_accounts
    puts "\n--- All Bank Accounts ---"
    accounts = @account_service.get_all_accounts
    if accounts.empty?
      puts "No accounts found."
    else
      accounts.each do |acc|
        puts "ID: #{acc.id} | Name: #{acc.name} | Balance: $#{acc.balance}"
      end
    end
  end

  def create_atm
    puts "\n--- Add New ATM ---"
    location = prompt("ATM Location")
    atm = @atm_service.create_atm(location: location)
    if atm.respond_to?(:id)
      puts "ATM created successfully! ATM ID: #{atm.id}"
    else
      puts "Error creating ATM."
    end
  end

  def deposit_money
    puts "\n--- Deposit Money ---"
    account, atm, amount = gather_account_atm_and_amount("deposit")
    return unless account

    DB.transaction do
      @account_service.update_balance(account.id, account.balance + amount)
      @atm_service.update_balance(atm.id, atm.balance + amount)
      @transaction_service.create_transaction(
        account_id: account.id,
        atm_id:     atm.id,
        amount:     amount,
        type:       'deposit'
      )
    end

    puts "Deposit successful. New balance: $#{account.balance + amount}"
  end

  def withdraw_money
    puts "\n--- Withdraw Money ---"
    account, atm, amount = gather_account_atm_and_amount("withdraw")
    return unless account

    withdrawn_today = @transaction_service.get_withdrawn_today(account.id)
    if err = @account_service.can_withdraw?(account, amount, withdrawn_today)[:error]
      return puts "Error: #{err}"
    end
    if err = @atm_service.can_withdraw?(atm, amount)[:error]
      return puts "Error: #{err}"
    end

    DB.transaction do
      @account_service.update_balance(account.id, account.balance - amount)
      @atm_service.update_balance(atm.id, atm.balance - amount)
      @transaction_service.create_transaction(
        account_id: account.id,
        atm_id:     atm.id,
        amount:     amount,
        type:       'withdraw'
      )
    end

    puts "Withdrawal successful. New balance: $#{account.balance - amount}"
  end

  def transfer_money
    puts "\n--- Transfer Money ---"
    from_acc = select_account("sender") or return
    to_acc   = select_account("receiver") or return
    amount   = prompt_amount("transfer") or return

    if amount > from_acc.balance
      return puts "Error: Insufficient funds. Current balance is $#{from_acc.balance}."
    end

    DB.transaction do
      @account_service.update_balance(from_acc.id, from_acc.balance - amount)
      @account_service.update_balance(to_acc.id,   to_acc.balance   + amount)
      @transaction_service.create_transfer(
        account_id: from_acc.id,
        target_id:  to_acc.id,
        amount:     amount
      )
    end

    puts "Transfer successful: $#{amount} from ##{from_acc.id} → ##{to_acc.id}"
  end

  def list_transactions
    puts "\n--- List Transactions ---"
    account_id = prompt("Enter Account ID").to_i
    result = @account_service.get_account(account_id)
    return puts "Error: #{result[:error]}" if result[:error]

    account = result[:account]
    transactions = @transaction_service.get_transactions_for_account(account.id)

    puts "\nTransactions for Account ##{account.id} (#{account.name}):"
    puts @transaction_service.format_transactions(transactions)
  end

  #––– Helpers –––#

  def gather_account_atm_and_amount(action)
    account = select_account or return
    atm     = select_atm     or return
    amount  = prompt_amount(action) or return
    [account, atm, amount]
  end

  def select_account(role = nil)
    accounts = @account_service.get_all_accounts
    if accounts.empty?
      puts "No accounts available."
      return nil
    end
    accounts.each { |acc| puts "ID: #{acc.id} | Name: #{acc.name}" }
    label = role ? "#{role.capitalize} " : ""
    id = prompt("Select #{label}Account ID").to_i
    account = accounts.find { |a| a.id == id }
    unless account
      puts "Error: Account not found."
      return nil
    end
    account
  end

  def select_atm
    atms = @atm_service.get_all_atms
    if atms.empty?
      puts "No ATMs available."
      return nil
    end
    atms.each_with_index { |atm, idx| puts "#{idx+1}. #{atm.location}" }
    idx = prompt("Select ATM").to_i - 1
    atm = atms[idx]
    unless atm
      puts "Error: ATM not found."
      return nil
    end
    atm
  end

  def prompt_amount(action)
    amt = prompt("Amount to #{action}").to_f
    if amt <= 0
      puts "Error: Amount must be positive."
      return nil
    end
    amt
  end
end
