# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage school funded FIP", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "Manage school funded FIP Induction Coordinator" do
    given_there_is_a_cip_only_school
    and_i_am_signed_in_as_an_induction_coordinator_for_a_school
    when_i_am_on_choose_programme_page_and_choose(labels: ["Deliver your own programme using DfE accredited materials (core induction programme)",
                                                           "We don’t expect to have any early career teachers starting in 2021"],
                                                  choice: "Use a training provider funded by your school",
                                                  snapshot: "School funded FIP - choose programme")
    then_i_should_see_the_school_funded_fip_success_page
    and_the_page_should_be_accessible
  end
end
