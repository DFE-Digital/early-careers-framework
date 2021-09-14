# frozen_string_literal: true

module Participants
  module EarlyCareerTeacher
    include ECF
    extend ActiveSupport::Concern
    included do
      extend EarlyCareerTeacherClassMethods
      delegate :early_career_teacher_profile, to: :user, allow_nil: true
    end

    def user_profile
      early_career_teacher_profile
    end

    def validate_participant_state(declaration_date, milestone)
      if (%w[withdrawn deferred] & user_profile.participant_profile_states.map(&:state)).any?
        raise ActionController::ParameterMissing, I18n.t(:declaration_on_incorrect_state) if declaration_date >= Time.zone.now

        active_state_date = user_profile.participant_profile_states.where(state: "active").order(:created_at).last.created_at
        unless active_state_date && active_state_date <= milestone.milestone_date.end_of_day
          raise ActionController::ParameterMissing, I18n.t(:declaration_on_incorrect_state)
        end
      end
    end

    module EarlyCareerTeacherClassMethods
      def valid_courses
        %w[ecf-induction]
      end
    end
  end
end
