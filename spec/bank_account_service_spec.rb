require 'spec_helper'
require_relative '../services/bank_account_service'
require_relative '../repositories/bank_account_repository'
require_relative '../models/bank_account'

RSpec.describe BankAccountService do
  let(:repo) { BankAccountRepository.new }
  let(:service) { BankAccountService.new(repo) }

  before(:each) do
    BankAccount.dataset.delete
  end

  it 'creates a new account and finds it by email' do
    result = service.create_account(name: 'Alice', job: 'Engineer', email: 'alice@example.com', address: '123 Main St')
    expect(result).to be_a(BankAccount)
    found = service.find_by_email('alice@example.com')
    expect(found).not_to be_nil
    expect(found.name).to eq('Alice')
  end

  it 'returns error for duplicate email' do
    service.create_account(name: 'Bob', job: 'Dev', email: 'bob@example.com', address: '456 Elm St')
    result = service.create_account(name: 'Bobby', job: 'Dev', email: 'bob@example.com', address: '789 Oak St')
    expect(result).to be_a(Hash)
    expect(result[:error]).to match(/already exists/)
  end

  it 'updates the balance of an account' do
    account = service.create_account(name: 'Carol', job: 'Analyst', email: 'carol@example.com', address: '789 Pine St')
    service.update_balance(account.id, 500.0)
    updated = service.get_account(account.id)[:account]
    expect(updated.balance).to eq(500.0)
  end

  it 'updates a single field of an account' do
    account = service.create_account(name: 'Dan', job: 'Manager', email: 'dan@example.com', address: '321 Oak St')
    service.update_field(account.id, 'name', 'Daniel')
    updated = service.get_account(account.id)[:account]
    expect(updated.name).to eq('Daniel')
  end

  it 'gets an account by id (success)' do
    account = service.create_account(name: 'Eve', job: 'QA', email: 'eve@example.com', address: '654 Spruce St')
    result = service.get_account(account.id)
    expect(result[:account]).not_to be_nil
    expect(result[:account].email).to eq('eve@example.com')
  end

  it 'returns error when getting a non-existent account' do
    result = service.get_account(9999)
    expect(result[:error]).to match(/not found/)
  end

  it 'returns all created accounts' do
    service.create_account(name: 'Frank', job: 'Dev', email: 'frank@example.com', address: '111 Cedar St')
    service.create_account(name: 'Grace', job: 'DevOps', email: 'grace@example.com', address: '222 Cedar St')
    accounts = service.get_all_accounts
    expect(accounts.size).to eq(2)
    emails = accounts.map(&:email)
    expect(emails).to include('frank@example.com', 'grace@example.com')
  end
end
