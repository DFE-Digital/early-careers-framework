# frozen_string_literal: true

module FormData
  class CohortSetupStore < DataStore
    def appropriate_body_appointed?
      get(:appropriate_body_appointed) == "yes"
    end

    def appropriate_body_id
      get :appropriate_body_id
    end

    def appropriate_body_type
      get :appropriate_body_type
    end

    def changing_answer?
      get(:changing_answer) == true
    end

    def cohort_start_year
      get :cohort_start_year
    end

    def complete?
      get(:complete) == true
    end

    def current_user
      get :current_user
    end

    def expect_any_ects?
      get(:expect_any_ects) == "yes"
    end

    def history_stack
      get(:history_stack) || []
    end

    def how_will_you_run_training
      get(:how_will_you_run_training)
    end

    def last_visited_step
      get(:last_visited_step)
    end

    def keep_providers?
      get(:keep_providers) == "yes"
    end

    def no_appropriate_body_appointed?
      get(:appropriate_body_appointed) == "no"
    end

    def no_expect_any_ects?
      get(:expect_any_ects) == "no"
    end

    def no_keep_providers?
      get(:keep_providers) == "no"
    end

    def return_point
      get(:return_point) || ""
    end

    def school_id
      get :school_id
    end

    def what_changes
      get :what_changes
    end
  end
end
