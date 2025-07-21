# Bank account class
# - attributes: name, job, email, address
# - methods:

class BankAccount
	attr_reader :id
	attr_accessor :name, :job, :email, :address

	def initialize(name, job, email, address)
		@name    = name
		@job     = job
		@email   = email
		@address = address
	end
end
