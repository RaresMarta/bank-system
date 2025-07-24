require_relative '../views/view'
require_relative '../views/bank_account_view'
require_relative '../views/transaction_view'
require_relative '../views/atm_view'
require_relative '../lib/validator'

class UserController
  def initialize(account_service, transaction_service, atm_service)
    @account_service = account_service
    @transaction_service = transaction_service
    @atm_service = atm_service
    @view = View.new
    @account_view = BankAccountView.new
    @transaction_view = TransactionView.new
    @atm_view = AtmView.new
    @validator = Validator.instance
    @current_user = nil
  end

  def run
    loop do
      @view.print_header("Welcome")
      @view.print_menu(["Register", "Login", "Exit"])
      choice = @view.prompt("Choose an option")
      case choice
      when '1' then register
      when '2' then login
      when '3' then break
      else @view.print_invalid_option
      end
    end
  end

  private

  def register
    @view.print_header("Register New Account")
    params = {
      name:    @view.prompt("Full Name"),
      job:     @view.prompt("Job Title"),
      email:   @view.prompt("Email Address"),
      address: @view.prompt("Full Address"),
      phone_number: @view.prompt("Phone Number")
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

  def login
    @view.print_header("Login")
    email = @view.prompt("Email Address")
    result = @account_service.find_by_email(email)
    if result.nil?
      @view.print_error("No account found with that email.")
      return
    end
    @current_user = result
    user_menu
  end

  def user_menu
    loop do
      @view.print_header("User Menu")
      @view.print_menu([
        "View Account",
        "Deposit",
        "Withdraw",
        "Transfer",
        "Edit Account",
        "View Transactions",
        "Log out"
      ])
      choice = @view.prompt("Choose an option")
      case choice
      when '1' then view_account
      when '2' then deposit
      when '3' then withdraw
      when '4' then transfer
      when '5' then edit_account
      when '6' then view_transactions
      when '7' then break
      else @view.print_invalid_option
      end
    end
    @current_user = nil
  end

  def view_account
    @account_view.list_accounts([@current_user])
  end

  def deposit
    atm = select_atm or return
    amount = prompt_amount("deposit")
    return unless amount
    @account_service.update_balance(@current_user.id, @current_user.balance + amount)
    @transaction_service.create_transaction(
      account_id: @current_user.id,
      atm_id: atm.id,
      amount: amount,
      type: 'deposit'
    )
    @view.print_success("Deposit successful. New balance: $#{@current_user.balance + amount}")
  end

  def withdraw
    atm = select_atm or return
    amount = prompt_amount("withdraw")
    return unless amount
    if amount > @current_user.balance
      @view.print_error("Insufficient funds.")
      return
    end
    @account_service.update_balance(@current_user.id, @current_user.balance - amount)
    @transaction_service.create_transaction(
      account_id: @current_user.id,
      atm_id: atm.id,
      amount: amount,
      type: 'withdraw'
    )
    @view.print_success("Withdrawal successful. New balance: $#{@current_user.balance - amount}")
  end

  def transfer
    accounts = @account_service.get_all_accounts.reject { |acc| acc.id == @current_user.id }
    if accounts.empty?
      @view.print_info("No other accounts available for transfer.")
      return
    end
    @view.print_info("Available accounts for transfer:")
    accounts.each { |acc| @view.print_info("ID: #{acc.id} | Name: #{acc.name}") }
    id = @view.prompt("Enter the ID of the recipient account")
    unless @validator.valid_id?(id)
      @view.print_invalid_id("account")
      return
    end
    id = id.to_i
    to_account = accounts.find { |a| a.id == id }
    unless to_account
      @view.print_error("Recipient not found.")
      return
    end
    amount = prompt_amount("transfer")
    return unless amount
    if amount > @current_user.balance
      @view.print_error("Insufficient funds.")
      return
    end
    @account_service.update_balance(@current_user.id, @current_user.balance - amount)
    @account_service.update_balance(to_account.id, to_account.balance + amount)
    @transaction_service.create_transfer(
      account_id: @current_user.id,
      target_id: to_account.id,
      amount: amount
    )
    @view.print_success("Transfer successful: $#{amount} to #{to_account.name}")
  end

  def edit_account
    @view.print_header("Edit Account - blank fields are not changed")
    fields = %w[name job email address]
    fields.each do |field|
      new_value = @view.prompt("New #{field.capitalize}")
      next if new_value.strip.empty?
      @account_service.update_field(@current_user.id, field, new_value)
    end
    @view.print_success("Account updated.")
  end

  def view_transactions
    transactions = @transaction_service.get_transactions_for_account(@current_user.id)
    @transaction_view.list_transactions(@current_user, transactions)
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
end
