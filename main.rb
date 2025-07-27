require_relative 'db/db'
require_relative 'db/schema'

# Ensure schema is ready before loading models
Schema.create unless DB.table_exists?(:bank_accounts)

require_relative 'repositories/bank_account_repository'
require_relative 'repositories/transaction_repository'
require_relative 'repositories/atm_repository'
require_relative 'services/bank_account_service'
require_relative 'services/transaction_service'
require_relative 'services/atm_service'
require_relative 'controllers/user_controller'
require_relative 'controllers/admin_controller'

account_repo = BankAccountRepository.new
transaction_repo = TransactionRepository.new
atm_repo = AtmRepository.new

transaction_service = TransactionService.new(transaction_repo)
account_service = BankAccountService.new(account_repo)
atm_service = AtmService.new(atm_repo)

controller = UserController.new(account_service, transaction_service, atm_service)
# controller = AdminController.new(account_service, transaction_service, atm_service)
controller.run
