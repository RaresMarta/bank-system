require_relative "view"

class BankAccountView < View
  def list_accounts(accounts)
    print_header("All Bank Accounts")
    if accounts.empty?
      puts "No accounts found."
    else
      accounts.each { |acc| puts acc }
    end
  end

  def creation_success(acc)
    print_success("Account created with ID: #{acc.id}")
  end

  def creation_failure(error)
    print_error("Failed to create account: #{error.message}")
  end

  def print_invalid_account_details
    print_error("Invalid account details.")
  end

  def print_invalid_account_id
    print_error("Invalid account ID.")
  end
end
