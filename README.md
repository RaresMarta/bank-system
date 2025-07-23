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

## Prerequisites

- Ruby
- PostgreSQL
- Bundler

## Getting Started

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-username/bank-system.git
    cd bank-system
    ```

2.  **Install dependencies:**
    ```sh
    bundle install
    ```

3.  **Set up the database:**
    - Create a PostgreSQL user and database.
    - Copy the example environment file:
      ```sh
      cp .env.example .env
      ```
    - Edit the `.env` file with your local database credentials.

4.  **Create the database tables:**
    Run the schema migration to set up the necessary tables.
    ```sh
    ruby -r './db/schema.rb' -e 'Schema.create'
    ```

5.  **Run the application:**
    ```sh
    ruby main.rb
    ```
