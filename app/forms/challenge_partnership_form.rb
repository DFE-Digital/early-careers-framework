# frozen_string_literal: true

class ChallengePartnershipForm
  include ActiveModel::Model

  # TODO: Does this form really needs anything apart partnership and challenge reason?
  attr_accessor :challenge_reason, :token, :school_name, :provider_name, :partnership
  validates :challenge_reason, presence: { message: "Select a reason why you think this confirmation is incorrect" }

  # TODO: Should this be static?
  def challenge_reason_options
    [
      OpenStruct.new(id: "another_provider", name: "I have already confirmed an agreement with another provider"),
      OpenStruct.new(id: "not_confirmed", name: "We have not confirmed an agreement"),
      OpenStruct.new(id: "do_not_recognise", name: "I do not recognise this training provider"),
      OpenStruct.new(id: "no_ects", name: "We do not have any early career teachers this year"),
      OpenStruct.new(id: "mistake", name: "This looks like a mistake"),
    ]
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
