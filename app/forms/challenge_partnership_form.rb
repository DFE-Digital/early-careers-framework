# frozen_string_literal: true

class ChallengePartnershipForm
  include ActiveModel::Model

  attr_accessor :challenge_reason, :token, :school_name, :partnership_id
  validates :challenge_reason, presence: { message: "Select a reason why you think this confirmation is incorrect" }

  def challenge_reason_options
    %w[another_provider not_confirmed do_not_recognise no_ects mistake].map do |key|
      OpenStruct.new(id: key, name: I18n.t(key, scope: "partnerships.challenge_reasons"))
    end
  end

  def challenge!
    Partnerships::Challenge.call(partnership, challenge_reason)
  end

  def partnership
    @partnership ||= Partnership.find(partnership_id)
  end

  def lead_provider_name
    @lead_provider_name ||= partnership.lead_provider.name
  end

  def delivery_partner_name
    @delivery_partner_name ||= partnership.delivery_partner.name
  end
end
