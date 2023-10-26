# frozen_string_literal: true

module Archive
  class UserPresenter < RelicPresenter
    def trn
      relic.dig("attributes", "teacher_profile", "attributes", "trn") || "Not recorded"
    end

    def roles
      if meta["roles"].blank?
        "None"
      else
        meta["roles"].map(&:humanize).join(", ")
      end
    end

    def created_at
      Time.zone.parse(attribute(:created_at))
    end

    def participant_identities
      @participant_identities ||= ParticipantIdentityPresenter.wrap(attribute("participant_identities"))
    end

    def participant_profiles
      @participant_profiles ||= ParticipantProfilePresenter.wrap(attribute("participant_profiles"))
    end

    def induction_records
      @induction_records ||= InductionRecordPresenter.wrap(attribute("induction_records")).sort_by(&:start_date).reverse
    end

    def induction_records_for_profile(participant_profile)
      induction_records.select { |ir| ir.participant_profile_id == participant_profile.id }
    end

    def participant_declarations
      @participant_declarations ||= ParticipantDeclarationPresenter.wrap(attribute("participant_declarations")).sort_by(&:declaration_date)
    end

    def participant_declarations_for_profile(participant_profile)
      participant_declarations.select { |ir| ir.participant_profile_id == participant_profile.id }
    end
  end
end
