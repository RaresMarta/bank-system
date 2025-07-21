require_relative 'account.rb'

acc = BankAccount.new("Bares", "Medic", "bares@gmail.com", "cetatii 4")

puts "Account 1 - name: #{acc.name}, job: #{acc.job}, email: #{acc.email}, address: #{acc.address}"
