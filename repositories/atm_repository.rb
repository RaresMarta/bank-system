require_relative '../models/atm'

class AtmRepository
  def all
    Atm.all
  end

  def find(id)
    Atm[id]
  end

  def create(location:)
    Atm.create(location: location)
  end

  def update_balance(atm_id, new_balance)
    Atm.with_pk!(atm_id).update(balance: new_balance)
  end
end
