require_relative "view"

class BankAccountView < View
  def list_accounts(accounts)
    print_header("All Bank Accounts")
    if accounts.empty?
      print_info("No accounts found.")
    else
      accounts.each do |acc|
        print_info("ID: #{acc.id} | Name: #{acc.name} | Balance: $#{acc.balance} | Created: #{acc.created_at.strftime('%Y-%m-%d %H:%M')}")
      end
    end
  end

  def creation_success(account)
    print_success("Account created with ID: #{account.id}")
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
