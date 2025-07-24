class View
  def print_header(title)
    puts "\n--- #{title} ---"
  end

  def prompt(message)
    print "#{message}: "
    gets.chomp
  end

	def print_menu(options)
    options.each_with_index do |option, index|
      puts "#{index + 1}. #{option}"
    end
  end

  def print_invalid_option
    print_error("Invalid option. Please try again.")
  end

  def print_success(message)
    puts "Success: #{message}"
  end

  def print_error(message)
    puts "Error: #{message}"
  end

  def print_info(message)
    puts message
  end

  def print_invalid_field(field)
    print_error("Invalid #{field}.")
  end

  def print_invalid_id(object_type)
    print_error("Invalid #{object_type.capitalize} ID.")
  end

  def print_invalid_string(str)
    print_error("Invalid #{str}.")
  end
end
