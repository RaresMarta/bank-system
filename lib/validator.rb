require 'singleton'

class Validator
  include Singleton

  def valid_string?(value)
    value.is_a?(String) &&
    !value.strip.empty? &&
    !(value.strip =~ /\A\d+(\.\d+)?\z/)
  end

  def valid_email?(email)
    email.is_a?(String) && /\A[^@\s]+@[^@\s]+\z/.match?(email)
  end

  def valid_amount?(amount)
    (amount.is_a?(Numeric) || amount.to_s.match?(/\A\d+(\.\d+)?\z/)) && amount.to_f > 0
  end

  def valid_id?(id)
    id.to_s.match?(/\A\d+\z/) && id.to_i >= 0
  end

  def valid_account_params?(params)
    valid_string?(params[:name]) &&
    valid_string?(params[:job]) &&
    valid_email?(params[:email]) &&
    valid_string?(params[:address])
  end

  def valid_location?(location)
    valid_string?(location)
  end

  def valid_field(field, value)
    case field.to_s
    when "name", "job", "address"
      valid_string?(value)
    when "email"
      valid_email?(value)
    when "amount"
      valid_amount?(value)
    when "id"
      valid_id?(value)
    else
      false
    end
  end
end
