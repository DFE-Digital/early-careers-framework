# frozen_string_literal: true

class FutureDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && value > Time.zone.now
      record.class.to_s == "ParticipantOutcome::NPQ" ? record.errors.add(attribute, I18n.t(:future_date_outcomes, attribute:)) : record.errors.add(attribute, I18n.t(:future_date, attribute:))
    end
  end
end
