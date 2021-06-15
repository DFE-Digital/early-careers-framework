# frozen_string_literal: true

class ChallengePartnershipForm
  include ActiveModel::Model

  attr_accessor :challenge_reason, :token, :school_name, :lead_provider_name, :delivery_partner_name, :partnership
  validates :challenge_reason, presence: { message: "Select a reason why you think this confirmation is incorrect" }

  def challenge_reason_options
    %w[another_provider not_confirmed do_not_recognise no_ects mistake].map do |key|
      OpenStruct.new(id: key, name: I18n.t(key, scope: "partnerships.challenge_reasons"))
    end
  end

  def challenge!
    ActiveRecord::Base.transaction do
      partnership.challenge!(challenge_reason)
      partnership.event_logs.create!(
        event: :challenged,
        data: {
          reason: challenge_reason,
        },
      )

      partnership.lead_provider.users.each do |lead_provider_user|
        LeadProviderMailer.partnership_challenged_email(
          partnership: partnership,
          user: lead_provider_user,
        ).deliver_later
      end
    end
  end
end
