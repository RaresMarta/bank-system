require_relative 'repositories/bank_account_repository'
require_relative 'repositories/transaction_repository'
require_relative 'repositories/atm_repository'
require_relative 'services/bank_account_service'
require_relative 'services/transaction_service'
require_relative 'services/atm_service'
require_relative 'controllers/cli_controller'

# 1. Initialize Repositories
account_repo = BankAccountRepository.new
transaction_repo = TransactionRepository.new
atm_repo = AtmRepository.new

# 2. Initialize Services
transaction_service = TransactionService.new(transaction_repo)
account_service = BankAccountService.new(account_repo)
atm_service = AtmService.new(atm_repo)

# 3. Initialize Controller with both services
controller = CliController.new(account_service, transaction_service, atm_service)

# 4. Run the application
controller.run
