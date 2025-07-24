require_relative '../views/view'
require_relative '../views/bank_account_view'
require_relative '../views/atm_view'
require_relative '../views/transaction_view'
require_relative '../lib/validator'


class AdminController
  def initialize(account_service, transaction_service, atm_service)
    @account_service = account_service
    @transaction_service = transaction_service
    @atm_service = atm_service
    @view = View.new
    @account_view = BankAccountView.new
    @transaction_view = TransactionView.new
    @atm_view = AtmView.new
    @validator = Validator.instance
  end

  def run
    loop do
      print_menu
      choice = @view.prompt("Choose an option")
      case choice
      when '1' then create_account
      when '2' then list_accounts
      when '3' then deposit_money
      when '4' then withdraw_money
      when '5' then transfer_money
      when '6' then list_transactions
      when '7' then create_atm
      when '8' then break
      else @view.print_invalid_option
      end
    end
  end

  private

  def print_menu
    @view.print_header("Bank System CLI")
    @view.print_menu([
      "Create Account",
      "List Accounts",
      "Deposit Money",
      "Withdraw Money",
      "Transfer Money",
      "List Transactions",
      "Add ATM",
      "Exit"
    ])
  end

  def create_account
    @view.print_header("Create New Bank Account")
    params = {
      name:    @view.prompt("Full Name"),
      job:     @view.prompt("Job Title"),
      email:   @view.prompt("Email Address"),
      address: @view.prompt("Full Address")
    }

    invalid_fields = params.keys.reject { |field| @validator.valid_field(field, params[field]) }
    unless invalid_fields.empty?
      invalid_fields.each { |field| @view.print_invalid_field(field) }
      return
    end

    result = @account_service.create_account(**params)
    if result[:error]
      @account_view.creation_failure(result[:error])
    else
      @account_view.creation_success(result)
    end
  end

  def list_accounts
    accounts = @account_service.get_all_accounts
    @account_view.list_accounts(accounts)
  end

  def create_atm
    @view.print_header("Add New ATM")
    location = @view.prompt("ATM Location")
    unless @validator.valid_location?(location)
      @view.print_error("Invalid location")
      return
    end
    atm = @atm_service.create_atm(location)
    if atm.is_a?(Hash) && atm[:error]
      @atm_view.creation_failure(atm[:error])
    else
      @atm_view.creation_success(atm)
    end
  end

  def deposit_money
    @view.print_header("Deposit Money")
    account, atm, amount = get_account_atm_and_amount("deposit")
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
    @transaction_view.deposit_success(amount, account.balance + amount)
  end

  def withdraw_money
    @view.print_header("Withdraw Money")
    account, atm, amount = get_account_atm_and_amount("withdraw")
    return unless account
    return unless can_withdraw_from_account_and_atm?(account, atm, amount)
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
    @transaction_view.withdraw_success(amount, account.balance - amount)
  end

  def transfer_money
    @view.print_header("Transfer Money")
    from_acc = select_account("sender") or return
    to_acc   = select_account("receiver") or return
    amount   = prompt_amount("transfer") or return

    if amount > from_acc.balance
      @view.print_error("Insufficient funds #{from_acc.balance}")
      return
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

    @transaction_view.transfer_success(amount, from_acc.id, to_acc.id)
  end

  def list_transactions
    @view.print_header("List Transactions")
    account_id = @view.prompt("Enter Account ID")

    unless @validator.valid_id?(account_id)
      @view.print_invalid_id("account")
      return
    end

    account_id = account_id.to_i
    result = @account_service.get_account(account_id)
    return @view.print_error(result[:error]) if result[:error]

    account = result[:account]
    transactions = @transaction_service.get_transactions_for_account(account.id)
    @transaction_view.list_transactions(account, transactions)
  end

  #––– Helpers –––#

  def get_account_atm_and_amount(action)
    account = select_account or return
    atm     = select_atm     or return
    amount  = prompt_amount(action) or return
    [account, atm, amount]
  end

  def select_account(role = nil)
    accounts = @account_service.get_all_accounts
    if accounts.empty?
      @view.print_info("No accounts available.")
      return nil
    end
    accounts.each { |acc| @view.print_info("ID: #{acc.id} | Name: #{acc.name}") }

    label = role ? "#{role.capitalize} " : ""
    id = @view.prompt("Select #{label} Account ID")
    unless @validator.valid_id?(id)
      @view.print_invalid_id("account")
      return nil
    end
    id = id.to_i
    account = accounts.find { |a| a.id == id }
    unless account
      @view.print_error("Account not found.")
      return nil
    end
    account
  end

  def select_atm
    atms = @atm_service.get_all_atms
    @atm_view.list_atms(atms)
    return nil if atms.empty?

    idx = @view.prompt("Select ATM")
    unless @validator.valid_id?(idx)
      @view.print_invalid_id("atm")
      return nil
    end
    idx = idx.to_i - 1
    atm = atms[idx]
    unless atm
      @view.print_error("ATM not found.")
      return nil
    end
    atm
  end

  def prompt_amount(action)
    amt = @view.prompt("Amount to #{action}")
    unless @validator.valid_amount?(amt)
      @view.print_error("Amount must be a positive number.")
      return nil
    end
    amt = amt.to_f
    amt
  end

  def can_withdraw_from_account_and_atm?(account, atm, amount)
    withdrawn_today = @transaction_service.get_withdrawn_today(account.id)
    account_check = @account_service.can_withdraw?(account, amount, withdrawn_today)
    if account_check[:error]
      @transaction_view.withdraw_failure(account_check[:error])
      return false
    end

    atm_check = @atm_service.can_withdraw?(atm, amount)
    if atm_check[:error]
      @transaction_view.withdraw_failure(atm_check[:error])
      return false
    end
    return true
  end
end
