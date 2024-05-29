# frozen_string_literal: true

module FormData
  class AddParticipantStore < DataStore
    def to_s
      values = []
      store.map { |k, v| values << "#{k}->#{v}" }.join("\n")
    end

    def current_user
      get :current_user
    end

    def school_id
      get :school_id
    end

    def school_cohort_id
      get :school_cohort_id
    end

    def full_name
      get :full_name
    end

    # TRN entered by SIT
    def trn
      get :trn
    end

    # TRN returned from DQT record
    def confirmed_trn
      get :confirmed_trn
    end

    def date_of_birth
      get_date :date_of_birth
    end

    def induction_start_date
      get_date :induction_start_date
    end

    def start_date
      get_date :start_date
    end

    def email
      get :email
    end

    def nino
      get :nino
    end

    def participant_type
      get :participant_type
    end

    def ect_participant?
      participant_type == "ect"
    end

    def sit_mentor?
      participant_type == "self"
    end

    def mentor_participant?
      participant_type == "mentor"
    end

    def return_point
      get(:return_point) || ""
    end

    def changing_answer?
      get(:changing_answer) == true
    end

    def transfer?
      get(:transfer_confirmed) == "yes"
    end

    def mentor_id
      get(:mentor_id)
    end

    def appropriate_body_confirmed?
      get(:appropriate_body_confirmed) == "1"
    end

    def appropriate_body_id
      get :appropriate_body_id
    end

    def continue_current_programme?
      ["yes", true].include?(get(:continue_current_programme))
    end

    def join_school_programme
      get :join_school_programme
    end

    def join_current_cohort_school_programme?
      join_school_programme == "default_for_current_cohort"
    end

    def join_participant_cohort_school_programme?
      join_school_programme == "default_for_participant_cohort"
    end

    def join_school_programme?
      join_participant_cohort_school_programme? || join_current_cohort_school_programme?
    end

    def known_by_another_name?
      get(:known_by_another_name) == "yes"
    end

    def participant_profile
      get(:participant_profile)
    end

    def providers
      get(:providers)
    end

    def current_providers?
      providers == "current_providers"
    end

    def previous_providers?
      providers == "previous_providers"
    end

    def providers_chosen?
      current_providers? || previous_providers?
    end

    def was_withdrawn_participant?
      get(:was_withdrawn_participant) == true
    end

    def complete?
      get(:complete) == true
    end

    def last_visited_step
      get(:last_visited_step)
    end

    def history_stack
      get(:history_stack) || []
    end

    def ect_mentor?
      get(:ect_mentor) == true
    end
  end
end
