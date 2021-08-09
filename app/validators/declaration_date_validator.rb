# frozen_string_literal: true

class DeclarationDateValidator < ActiveModel::EachValidator
  RCF3339_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}T(\d{2}):(\d{2}):(\d{2})([\.,]\d+)?(Z|[+-](\d{2})(:?\d{2})?)?\z/i.freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t(:invalid_declaration_date)) unless value.match(RCF3339_DATE_REGEX)
  end
end
