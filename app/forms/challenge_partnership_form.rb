# frozen_string_literal: true

class ChallengePartnershipForm
  include ActiveModel::Model

  attr_accessor :challenge_reason, :token, :school_name, :provider_name, :partnership
  validates :challenge_reason, presence: { message: "Select a reason why you think this confirmation is incorrect" }

  CHALLANGE_REASON_OPTIONS = {
    another_provider: "I have already confirmed an agreement with another provider",
    not_confirmed: "We have not confirmed an agreement",
    do_not_recognise: "I do not recognise this training provider",
    no_ects: "We do not have any early career teachers this year",
    mistake: "This looks like a mistake",
  }.freeze

  def challenge_reason_options
    CHALLANGE_REASON_OPTIONS.map do |key, value|
      OpenStruct.new(id: key, name: value)
    end
  end

  def challenge!
    ActiveRecord::Base.transaction do
      partnership.challenge!(challenge_reason)

      partnership.lead_provider.users.each do |lead_provider_user|
        LeadProviderMailer.partnership_challenged_email(
          partnership: partnership,
          user: lead_provider_user,
        ).deliver_later
      end
    end
  end
end
