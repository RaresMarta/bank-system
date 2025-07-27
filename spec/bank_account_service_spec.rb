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
    let(:alice_attrs) do
      { name: 'Alice', job: 'Engineer', email: 'alice@example.com', address: '123 Main St' }
    end

    it 'creates a new account and returns the BankAccount object' do
      acct = service.create_account(**alice_attrs)
      expect(acct).to be_a(BankAccount)
      expect(acct.name).to eq('Alice')
      expect(acct.balance).to eq(0.0)
    end

    context 'when email already exists' do
      let(:dup_email) { 'dup@x.com' }
      let(:first_attrs) do
        { name: 'A', job: 'J', email: dup_email, address: 'A' }
      end
      let(:duplicate_attrs) do
        { name: 'B', job: 'K', email: dup_email, address: 'B' }
      end

      before do
        service.create_account(**first_attrs)
      end

      it 'raises a uniqueness error' do
        result = service.create_account(**duplicate_attrs)
        expect(result).to be_a(Hash)
        expect(result[:error]).to match(/already exists/)
      end
    end
  end

  describe '#find_by_email' do
    let(:email)     { 'bob@x.com' }
    let(:bob_attrs) { { name: 'Bob', job: 'Biz', email: email, address: 'Addr' } }

    context 'when the account exists' do
      before do
        service.create_account(**bob_attrs)
      end

      it 'returns the account' do
        acct = service.find_by_email(email)
        expect(acct).to be_a(BankAccount)
        expect(acct.email).to eq(email)
      end
    end

    context 'when no account has that email' do
      it 'returns nil' do
        expect(service.find_by_email('nope@x.com')).to be_nil
      end
    end
  end

  describe '#get_all_accounts' do
    let(:accounts_data) do
      [
        { name: 'U0', job: 'X', email: 'u0@x.com', address: 'A' },
        { name: 'U1', job: 'X', email: 'u1@x.com', address: 'A' },
        { name: 'U2', job: 'X', email: 'u2@x.com', address: 'A' }
      ]
    end

    before do
      accounts_data.each { |attrs| service.create_account(**attrs) }
    end

    it 'returns an array of all accounts' do
      all = service.get_all_accounts
      expect(all.size).to eq(3)
      expect(all).to all(be_a(BankAccount))
    end
  end

  describe '#get_account' do
    let(:acct) { service.create_account(name: 'C', job: 'J', email: 'c@x.com', address: 'A') }

    context 'when found' do
      it 'returns the account wrapped in a hash' do
        result = service.get_account(acct.id)
        expect(result).to include(:account)
        expect(result[:account].id).to eq(acct.id)
      end
    end

    context 'when not found' do
      it 'returns an error hash' do
        result = service.get_account(999)
        expect(result).to eq(error: "Account not found.")
      end
    end
  end

  describe '#update_balance' do
    let(:acct) { service.create_account(name: 'D', job: 'J', email: 'd@x.com', address: 'A') }

    it 'updates the balance correctly' do
      service.update_balance(acct.id, 123.45)
      reloaded = repo.find(acct.id)
      expect(reloaded.balance).to eq(123.45)
    end
  end

  describe '#update_field' do
    let(:acct)    { service.create_account(name: 'E', job: 'OldJob', email: 'e@x.com', address: 'A') }
    let(:new_job) { 'NewJob' }

    it 'updates a given field on the account' do
      service.update_field(acct.id, 'job', new_job)
      reloaded = repo.find(acct.id)
      expect(reloaded.job).to eq(new_job)
    end
  end

  describe '#can_withdraw?' do
    let(:acct) { service.create_account(name: 'F', job: 'J', email: 'f@x.com', address: 'A') }

    context 'with non-positive amounts' do
      it 'rejects non-positive amounts' do
        result = service.can_withdraw?(acct, -5.0, 0.0)
        expect(result).to include(:error)
        expect(result[:error]).to match(/Withdrawal amount must be positive\./)
      end
    end

    context 'with insufficient funds' do
      it 'rejects insufficient funds' do
        result = service.can_withdraw?(acct, 1.0, 0.0)
        expect(result).to include(:error)
        expect(result[:error]).to match(/Insufficient funds\./)
      end
    end

    context 'when daily limit exceeded' do
      before { service.update_balance(acct.id, 10_000.0) }

      it 'rejects when daily limit exceeded' do
        result = service.can_withdraw?(acct, 1_000.0, BankAccountService::DAILY_WITHDRAWAL_LIMIT)
        expect(result).to include(:error)
        expect(result[:error]).to match(/Daily withdrawal limit/)
      end
    end

    context 'with valid withdrawal' do
      before { service.update_balance(acct.id, 1_000.0) }

      it 'allows valid withdrawal' do
        result = service.can_withdraw?(acct, 200.0, 0.0)
        expect(result).to eq(ok: true)
      end
    end
  end
end
