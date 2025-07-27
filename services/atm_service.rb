class AtmService
  def initialize(atm_repo)
    @atm_repo = atm_repo
  end

  def get_all_atms
    @atm_repo.all
  end

  def get_atm(id)
  	@atm_repo.find(id)
    atm ? { atm: atm } : { error: "Atm not found." }
  end

  def create_atm(location)
    @atm_repo.create(location: location)
  rescue Sequel::UniqueConstraintViolation, Sequel::ValidationFailed
    { error: "An ATM already exists at this location." }
  end

  def update_balance(atm_id, new_balance)
    @atm_repo.update_balance(atm_id, new_balance)
  end

  def can_withdraw?(atm, amount)
    return { error: "ATM does not have enough cash." } if atm.balance < amount
    { ok: true }
  end
end
