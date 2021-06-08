# frozen_string_literal: true

# Notify email validation https://github.com/alphagov/notifications-utils/blob/acbe764fb7f12c7a8b0696156283fbcb5073fcd7/notifications_utils/recipients.py#L494
class NotifyEmailValidator < ActiveModel::EachValidator
  HOSTNAME_PART_REGEX = /\A(xn|[a-z0-9]+)(-?-[a-z0-9]+)*\z/i.freeze
  TLD_REGEX = /\A([a-z]{2,63}|xn--([a-z0-9]+-)*[a-z0-9]+)\z/i.freeze
  EMAIL_REGEX = /\A[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~\\-]+@([^.@][^@\s]+)\z/.freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t("errors.email.invalid")) unless NotifyEmailValidator.valid?(value)
  end

  def self.valid?(email)
    return false if email.blank?

    email_match = email.match(EMAIL_REGEX)
    return false unless email_match
    return false if email.length > 320
    return false if email.include?("..")

    hostname = email_match[1]

    parts = hostname.split(".")
    return false if hostname.length > 253 || parts.length < 2
    return false if parts.any? { |part| part.blank? || part.length > 63 || part.match(HOSTNAME_PART_REGEX).nil? }
    return false unless parts.last.match(TLD_REGEX)

    true
  end
end
