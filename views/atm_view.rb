require_relative "view"

class AtmView < View
  def list_atms(atms)
    print_header("ATM List")
    if atms.empty?
      puts "No ATMs available."
    else
      atms.each { |atm| puts atm }
    end
  end

  def creation_success(atm)
    print_success("ATM created with ID: #{atm.id}")
  end

  def creation_failure(error)
    print_error("Failed to create ATM: #{error.message}")
  end

  def print_invalid_location
    print_invalid_string("ATM location.")
  end

  def print_invalid_atm_id
    print_error("Invalid ATM ID.")
  end
end
