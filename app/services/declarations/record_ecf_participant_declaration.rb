# frozen_string_literal: true

module Declarations
  class RecordECFParticipantDeclaration < RecordParticipantDeclaration
    def course_valid_for_participant?
      early_career_teacher? && course == "ecf-induction" ||
        mentor? && course == "ecf-mentor"
    end

    def user_profile
      if early_career_teacher?
        early_career_teacher_profile
      elsif mentor?
        mentor_profile
      else
        false
      end
    end

    def declaration_type
      ParticipantDeclaration::ECF
    end

    def actual_lead_provider
      SchoolCohort.find_by(school: school, cohort: cohort)&.lead_provider&.cpd_lead_provider if early_career_teacher? || mentor?
    end
  end
end
