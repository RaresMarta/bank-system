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
      @view.print_menu([
        "Register",
        "Login",
        "Exit"
      ])
      choice = @view.prompt("Choose an option")
      case choice
      when '1' then create_account
      when '2' then login
      when '3' then break
      else @view.print_invalid_option
      end
    end
  end

  private

  def create_account
    @view.print_header("Register New Account")

    params = {
      name:    @view.prompt("Full Name"),
      job:     @view.prompt("Job Title"),
      email:   @view.prompt("Email Address"),
      address: @view.prompt("Full Address"),
    }

    invalid_fields = params.keys.reject { |field| @validator.valid_field(field, params[field]) }
    if invalid_fields.any?
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
    refresh_user
    @account_view.print_account(@current_user)
  end

  def deposit
    @view.print_header("Deposit Money")

    atm, amount = get_atm_and_amount_for("deposit")
    return unless amount

    DB.transaction do
      @account_service.update_balance(@current_user.id, @current_user.balance + amount)
      @atm_service.update_balance(atm.id, atm.balance + amount)
      @transaction_service.create_transaction(
        account_id: @current_user.id,
        atm_id: atm.id,
        amount: amount,
        type: 'deposit'
      )
    end

    refresh_user
    @transaction_view.deposit_success(amount, @current_user.balance)
  end

  def withdraw
    @view.print_header("Withdraw Money")
    atm, amount = get_atm_and_amount_for("withdraw")
    return unless amount && can_withdraw_from_account_and_atm?(atm, amount)

    DB.transaction do
      @account_service.update_balance(@current_user.id, @current_user.balance - amount)
      @atm_service.update_balance(atm.id, atm.balance - amount)
      @transaction_service.create_transaction(
        account_id: @current_user.id,
        atm_id: atm.id,
        amount: amount,
        type: 'withdraw'
      )
    end
    refresh_user
    @transaction_view.withdraw_success(amount, @current_user.balance)
  end

  def transfer
    @view.print_header("Transfer Money")
    recipient = select_recipient_account
    amount = prompt_amount("transfer")
    return unless amount

    if amount > @current_user.balance
      @transaction_view.transfer_failure("Insufficient funds #{@current_user.balance}")
      return
    end

    DB.transaction do
      @account_service.update_balance(@current_user.id, @current_user.balance - amount)
      @account_service.update_balance(recipient.id, recipient.balance + amount)
      @transaction_service.create_transfer(
        account_id: @current_user.id,
        target_id: recipient.id,
        amount: amount
      )
    end

    @transaction_view.transfer_success(amount, @current_user.id, recipient.id)
  end

  def select_recipient_account
    accounts = @account_service.get_all_accounts.reject { |acc| acc.id == @current_user.id }

    if accounts.empty?
      @view.print_info("No accounts available.")
      return nil
    end

    @view.print_info("Available accounts for transfer:")
    accounts.each { |acc| @view.print_info("ID: #{acc.id} | Name: #{acc.name}") }

    id = @view.prompt("Select account ID")
    unless @validator.valid_id?(id)
      @view.print_error("Invalid Account ID.")
      return nil
    end

    id = id.to_i
    account = accounts.find { |a| a.id == id }
    unless account
      @transaction_view.transfer_failure("Recipient not found.")
      return nil
    end

    account
  end

  def edit_account
    @view.print_header("Edit Account - blank fields are not changed")

    %w[name job email address].each do |field|
      current_value = account.send(field)
      new_value = @view.prompt("New #{field.capitalize} (current: #{current_value})")
      next if new_value.strip.empty?
      @account_service.update_field(@current_user.id, field, new_value)
    end

    @view.print_success("Account updated.")
  end

  def view_transactions
    transactions = @transaction_service.get_transactions_for_account(@current_user.id)
    @transaction_view.list_transactions(@current_user, transactions)
  end

  def get_atm_and_amount_for(action)
    atm = select_atm or return
    amount = prompt_amount(action) or return
    [atm, amount]
  end

  def select_atm
    atms = @atm_service.get_all_atms
    @atm_view.list_atms(atms)
    return nil if atms.empty?

    idx = @view.prompt("Select ATM")
    unless @validator.valid_id?(idx)
      @view.print_error("Invalid Atm ID.")
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
    amount = @view.prompt("Amount to #{action}")

    unless @validator.valid_amount?(amount)
      @view.print_error("Amount must be a positive number.")
      return nil
    end

    amount = amount.to_f
    amount
  end

  def can_withdraw_from_account_and_atm?(atm, amount)
    if amount > @current_user.balance
      @transaction_view.withdraw_failure("Insufficient funds.")
      return false
    end

    withdrawn_today = @transaction_service.get_withdrawn_today(@current_user.id)
    account_check = @account_service.can_withdraw?(@current_user, amount, withdrawn_today)

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

  def refresh_user
    @current_user = @account_service.get_account(@current_user.id)[:account]
  end
end
