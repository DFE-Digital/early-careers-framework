# frozen_string_literal: true

class ChallengePartnershipForm
  include Multistep::Form

  REASON_OPTIONS = %w[no_ects do_not_recognise another_provider not_confirmed mistake].freeze

  attribute :partnership_id

  step :reason do
    attribute :challenge_reason

    validates :challenge_reason,
              presence: { message: I18n.t("errors.challenge_reason.blank") },
              inclusion: { in: REASON_OPTIONS }

    next_step { :confirm }
  end

  step :confirm

  def challenge_reason_options
    REASON_OPTIONS.map do |key|
      OpenStruct.new(id: key, name: I18n.t(key, scope: "partnerships.challenge_reasons"))
    end
  end

  def save!
    Partnerships::Challenge.call(partnership, challenge_reason)
  end

  def partnership
    @partnership ||= Partnership.find(partnership_id)
  end

  def partnership=(partnership)
    self.partnership_id = partnership&.id
    @partnership = partnership
  end

  def school_name
    partnership.school.name
  end

  def lead_provider_name
    @lead_provider_name ||= partnership.lead_provider.name
  end

  def delivery_partner_name
    @delivery_partner_name ||= partnership.delivery_partner.name
  end
end
