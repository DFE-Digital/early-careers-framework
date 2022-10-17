# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class NPQ < ParticipantProfile
    COURSE_IDENTIFIERS = %w[
      npq-executive-leadership
      npq-headship
      npq-senior-leadership
      npq-early-years-leadership
      npq-additional-support-offer
      npq-leading-teaching-development
      npq-leading-teaching
      npq-leading-behaviour-culture
      npq-early-headship-coaching-offer
      npq-leading-literacy
    ].freeze
    VALID_EVIDENCE_HELD = %w[training-event-attended self-study-material-completed other].freeze
    self.ignored_columns = %i[mentor_profile_id school_cohort_id start_term]
    belongs_to :school, optional: true
    belongs_to :npq_course, optional: true

    has_one :npq_application, foreign_key: :id

    has_many :participant_declarations, class_name: "ParticipantDeclaration::NPQ", foreign_key: :participant_profile_id

    after_commit :push_profile_to_big_query

    self.validation_steps = %i[identity decision].freeze

    def npq?
      true
    end

    def ecf?
      false
    end

    def approved?
      validation_decision(:decision).approved?
    end

    def rejected?
      decision = validation_decision(:decision)
      decision.persisted? && !decision.approved?
    end

    def participant_type
      :npq
    end

    def fundable?
      npq_application&.eligible_for_dfe_funding
    end

    def schedule_for(*)
      schedule
    end

    def withdrawn_for?(*)
      training_status_withdrawn?
    end

    def deferred_for?(*)
      training_status_deferred?
    end

    def latest_induction_record_for(*)
      nil
    end

    def policy_class
      ParticipantProfile::NPQPolicy
    end

  private

    def push_profile_to_big_query
      ::NPQ::StreamBigQueryProfileJob.perform_later(profile_id: id)
    end
  end
end
