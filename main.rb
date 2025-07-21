require_relative 'repositories/bank_account_repository'
require_relative 'repositories/transaction_repository'
require_relative 'services/bank_account_service'
require_relative 'services/transaction_service'
require_relative 'controllers/cli_controller'

# 1. Initialize Repositories
account_repo = BankAccountRepository.new
transaction_repo = TransactionRepository.new

# 2. Initialize Services
transaction_service = TransactionService.new(transaction_repo)
account_service = BankAccountService.new(account_repo, transaction_service)

# 3. Initialize Controller with both services
controller = CliController.new(account_service, transaction_service)

# 4. Run the application
controller.run
