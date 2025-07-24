require 'spec_helper'
require_relative '../services/bank_account_service'
require_relative '../repositories/bank_account_repository'
require_relative '../models/bank_account'

RSpec.describe BankAccountService do
  let(:repo)    { BankAccountRepository.new }
  let(:service) { BankAccountService.new(repo) }

  before(:each) do
    BankAccount.dataset.delete
  end

  describe '#create_account' do
    it 'creates a new account and returns the BankAccount object' do
      acct = service.create_account(
        name:    'Alice',
        job:     'Engineer',
        email:   'alice@example.com',
        address: '123 Main St'
      )
      expect(acct).to be_a(BankAccount)
      expect(acct.name).to eq('Alice')
      expect(acct.balance).to eq(0.0)
    end

    it 'raises a uniqueness error when email already exists' do
      service.create_account(name: 'A', job: 'J', email: 'dup@x.com', address: 'A')
      result = service.create_account(name: 'B', job: 'K', email: 'dup@x.com', address: 'B')
      expect(result).to be_a(Hash)
      expect(result[:error]).to match(/already exists/)
    end
  end

  describe '#find_by_email' do
    it 'returns the account when it exists' do
      service.create_account(name: 'Bob', job: 'Biz', email: 'bob@x.com', address: 'Addr')
      acct = service.find_by_email('bob@x.com')
      expect(acct).to be_a(BankAccount)
      expect(acct.email).to eq('bob@x.com')
    end

    it 'returns nil when no account has that email' do
      expect(service.find_by_email('nope@x.com')).to be_nil
    end
  end

  describe '#get_all_accounts' do
    it 'returns an array of all accounts' do
      3.times { |i| service.create_account(name: "U#{i}", job: 'X', email: "u#{i}@x.com", address: 'A') }
      all = service.get_all_accounts
      expect(all.size).to eq(3)
      expect(all).to all(be_a(BankAccount))
    end
  end

  describe '#get_account' do
    it 'returns the account wrapped in a hash when found' do
      acct = service.create_account(name: 'C', job: 'J', email: 'c@x.com', address: 'A')
      result = service.get_account(acct.id)
      expect(result).to include(:account)
      expect(result[:account].id).to eq(acct.id)
    end

    it 'returns an error hash when not found' do
      result = service.get_account(999)
      expect(result).to eq(error: "Account not found.")
    end
  end

  describe '#update_balance' do
    it 'updates the balance correctly' do
      acct = service.create_account(name: 'D', job: 'J', email: 'd@x.com', address: 'A')
      service.update_balance(acct.id, 123.45)
      reloaded = repo.find(acct.id)
      expect(reloaded.balance).to eq(123.45)
    end
  end

  describe '#update_field' do
    it 'updates a given field on the account' do
      acct = service.create_account(name: 'E', job: 'OldJob', email: 'e@x.com', address: 'A')
      service.update_field(acct.id, 'job', 'NewJob')
      reloaded = repo.find(acct.id)
      expect(reloaded.job).to eq('NewJob')
    end
  end

  describe '#can_withdraw?' do
    let(:acct) { service.create_account(name: 'F', job: 'J', email: 'f@x.com', address: 'A') }

    it 'rejects non-positive amounts' do
      result = service.can_withdraw?(acct, -5.0, 0.0)
      expect(result).to include(:error)
      expect(result[:error]).to match(/Withdrawal amount must be positive\./)
    end

    it 'rejects insufficient funds' do
      result = service.can_withdraw?(acct, 1.0, 0.0)
      expect(result).to include(:error)
      expect(result[:error]).to match(/Insufficient funds\./)
    end

    it 'rejects when daily limit exceeded' do
      # give acct some balance
      service.update_balance(acct.id, 10000.0)
      result = service.can_withdraw?(acct, 1000.0, BankAccountService::DAILY_WITHDRAWAL_LIMIT)
      expect(result).to include(:error)
      expect(result[:error]).to match(/Daily withdrawal limit/)
    end

    it 'allows valid withdrawal' do
      service.update_balance(acct.id, 1000.0)
      result = service.can_withdraw?(acct, 200.0, 0.0)
      expect(result).to eq(ok: true)
    end
  end
end
