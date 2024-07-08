# frozen_string_literal: true

class NominationEmail < ApplicationRecord
  belongs_to :school
  belongs_to :partnership_notification_email, optional: true

  self.filter_attributes += %i[sent_to]

  NOMINATION_EXPIRY_TIME = 21.days

  def self.create_nomination_email(sent_at:, sent_to:, school:, partnership_notification_email: nil)
    NominationEmail.create!(
      sent_at:,
      sent_to:,
      school:,
      token: generate_token,
      partnership_notification_email:,
    )
  end

  def expired?
    !sent_within_last?(NOMINATION_EXPIRY_TIME)
  end

  def sent_within_last?(relative_time)
    (sent_at + relative_time) > Time.zone.now
  end

  def nomination_url(utm_source: :nominate_tutor)
    Rails.application.routes.url_helpers.start_nominate_induction_coordinator_url(
      token:,
      host: Rails.application.config.domain,
      **UTMService.email(utm_source, utm_source),
    )
  end

  def plain_nomination_url
    Rails.application.routes.url_helpers.start_nominate_induction_coordinator_url(token:, host: Rails.application.config.domain)
  end

  def self.generate_token
    loop do
      value = SecureRandom.hex(16)
      break value unless NominationEmail.exists?(token: value)
    end
  end

  private_class_method :generate_token
end
