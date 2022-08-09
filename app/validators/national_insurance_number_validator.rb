# frozen_string_literal: true

class NationalInsuranceNumberValidator < ActiveModel::EachValidator
  DEFAULT_MESSAGE_SCOPE = "errors.national_insurance_number"

  attr_reader :nino

  def validate_each(record, attribute, value)
    @nino = NationalInsuranceNumber.new(value)
    record.errors.add(attribute, error_message) unless nino.valid?
  end

private

  def error_message
    options[:message] || I18n.t(nino.error, scope: message_scope)
  end

  def message_scope
    options[:message_scope] || DEFAULT_MESSAGE_SCOPE
  end
end
