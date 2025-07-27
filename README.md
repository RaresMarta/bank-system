# Bank System CLI

A CLI application for managing a simple banking system, built with Ruby, Sequel, and PostgreSQL.

## Features

- Create bank accounts
- Deposit and withdraw funds
- Transfer funds between accounts
- View transaction history for an account
- Enforces a daily withdrawal limit

## Architecture

This project follows a modern Controller-Service-Repository architecture to ensure a clean separation of concerns:
- **Controllers:** Handle all user interaction (CLI prompts).
- **Services:** Contain the core business logic (e.g., withdrawal rules).
- **Repositories:** Manage all database queries and interactions.
- **Models:** Simple data objects representing database tables.

## Running the App with Docker

1. **Create a `.env` file** in the project root with the following variables:
   ```env
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   DB_NAME=your_db_name
   ```
   (Replace values as needed. These will be used by the PostgreSQL container.)

2. **Make the script executable (if needed):**
   ```sh
   chmod +x run.sh
   ```

3. **Run the app using the script:**
   ```sh
   ./run.sh
   ```
   This script builds the app image, starts the database, and launches the CLI interactively.

4. **Run tests:**
   ```sh
   docker compose run --rm test
   ```

5. **Stop the services when done:**
   ```sh
   docker compose down
   ```
