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
      @view.print_header("Bank Admin CLI")
      @view.print_menu([
        "Create Account",
        "Create ATM",
        "List Accounts",
        "List Transactions",
        "List ATMs",
        "Edit Account",
        "Edit ATM",
        "Exit"
      ])

      choice = @view.prompt("Choose an option")
      case choice
      when '1' then create_account
      when '2' then create_atm
      when '3' then list_accounts
      when '4' then list_transactions
      when '5' then list_atms
      when '6' then edit_account
      when '7' then edit_atm
      when '8' then break
      else @view.print_invalid_option
      end
    end
  end

  private

  def create_account
    @view.print_header("Create New Bank Account")

    params = {
      name:    @view.prompt("Full Name"),
      job:     @view.prompt("Job Title"),
      email:   @view.prompt("Email Address"),
      address: @view.prompt("Full Address")
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

  def create_atm
    @view.print_header("Add New ATM")

    location = @view.prompt("ATM Location")
    unless @validator.valid_location?(location)
      @atm_view.creation_failure("Invalid location")
      return
    end

    atm = @atm_service.create_atm(location)
    if atm.is_a?(Hash) && atm[:error]
      @atm_view.creation_failure(atm[:error])
    else
      @atm_view.creation_success(atm)
    end
  end

  def list_accounts
    accounts = @account_service.get_all_accounts
    @account_view.list_accounts(accounts)
  end

  def list_transactions
    @view.print_header("List Transactions")
    account_id = @view.prompt("Enter Account ID")

    unless @validator.valid_id?(account_id)
      @view.print_error("Invalid Account ID.")
      return
    end

    account_id = account_id.to_i
    result = @account_service.get_account(account_id)
    return @view.print_error(result[:error]) if result[:error]

    account = result[:account]
    transactions = @transaction_service.get_transactions_for_account(account.id)
    @transaction_view.list_transactions(account, transactions)
  end

  def list_atms
    atms = @atm_service.get_all_atms
    @atm_view.list_atms(atms)
  end

  def edit_account
    @view.print_header("Edit Account - blank fields are not changed")

    account_id = @view.prompt("Enter Account ID to edit")
    unless @validator.valid_id?(account_id)
      @view.print_error("Invalid Account ID.")
      return
    end

    account_id = account_id.to_i
    result = @account_service.get_account(account_id)
    if result[:error]
      @view.print_error(result[:error])
      return
    end

    account = result[:account]
    print_info(account)

    %w[name job email address].each do |field|
      current_value = account.public_send(field)
      new_value = @view.prompt("New #{field.capitalize} (current: #{current_value})")
      next if new_value.strip.empty?
      @account_service.update_field(account_id, field, new_value)
    end

    @view.print_success("Account updated.")
  end

  def edit_atm
    @view.print_header("Edit ATM - blank fields are not changed")
    atms = @atm_service.get_all_atms
    @atm_view.list_atms(atms)
    return if atms.empty?

    choice = @view.prompt("Select ATM number to edit")
    unless @validator.valid_id?(choice)
      @view.print_error("Invalid ATM selection.")
      return
    end

    idx = choice.to_i - 1
    atm = atms[idx]
    unless atm
      @view.print_error("ATM not found.")
      return
    end

    new_location = @view.prompt("New Location (current: #{atm.location})")
    if new_location.strip.empty?
      @view.print_success("No changes made.")
      return
    end

    @atm_service.update_location(atm.id, new_location)
    @view.print_success("ATM updated.")
  end
end
