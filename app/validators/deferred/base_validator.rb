# frozen_string_literal: true

module Deferred
  class BaseValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, I18n.t("errors.defer_reason.invalid")) unless valid?(value)
    end

    def valid?(value)
      self.class.reasons.map(&:downcase).include?(value.to_s.downcase)
    end
  end
end
