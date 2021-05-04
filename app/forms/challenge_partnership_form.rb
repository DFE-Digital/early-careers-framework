# frozen_string_literal: true

class ChallengePartnershipForm
  include ActiveModel::Model

  attr_accessor :challenge_reason, :token, :school_name, :provider_name, :partnership
  validates :challenge_reason, presence: { message: "Select a reason why you think this confirmation is incorrect" }

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
    partnership.challenge!(challenge_reason)
  end
end
