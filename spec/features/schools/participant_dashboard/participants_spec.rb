# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Manage FIP unpartnered participants", js: true do
  include ManageTrainingSteps

  scenario "Include participants from 2021 and onwards" do
    given_there_is_a_school_with_participants_in_every_cohort_since_2021

    travel_to Cohort.next.registration_start_date do
      and_i_sign_in_as_the_user_with_the_email @sit.user.email
      when_i_navigate_to_ect_dashboard
      then_i_should_see_the_participant_from_the_2021_cohort
    end
  end
end
