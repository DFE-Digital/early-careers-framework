# frozen_string_literal: true

class TeacherReferenceNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    trn = TeacherReferenceNumber.new(value)
    unless trn.valid?
      message_scope = (options[:message_scope] || "errors.teacher_reference_number")
      record.errors.add(attribute, (options[:message] || I18n.t(trn.format_error, scope: message_scope)))
    end
  end
end
