# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reporting participants without a known TRN",
               with_feature_flags: { change_of_circumstances: "active" },
               type: :feature,
               js: true do
  let!(:cohort) { create :cohort, start_year: 2021 }
  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let(:participant_data) do
    {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      email: "sally@school.com",
      nino: "",
      start_date: Date.new(2022, 9, 1),
    }
  end

  let!(:school) { create :school, name: "Fip School" }
  let!(:school_cohort) { create :school_cohort, school:, cohort: Cohort.next, induction_programme_choice: "full_induction_programme" }
  let!(:induction_programme) do
    induction_programme = create(:induction_programme, :fip, school_cohort:)
    school_cohort.update! default_induction_programme: induction_programme
    induction_programme
  end
  let!(:partnership) do
    create :partnership,
           school:,
           lead_provider: create(:lead_provider, name: "Big Provider Ltd"),
           delivery_partner: create(:delivery_partner, name: "Amazing Delivery Team"),
           cohort: Cohort.next,
           challenge_deadline: 2.weeks.ago
  end
  let(:mentor_full_name) { "Billy Mentor" }
  let!(:mentor) do
    user = create(:user, full_name: "Billy Mentor", email: "billy-mentor@example.com")
    teacher_profile = create(:teacher_profile, user:)
    participant_profile_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort:)
    Induction::Enrol.call(participant_profile: participant_profile_mentor, induction_programme:)
    participant_profile_mentor
  end
  let!(:induction_coordinator) do
    sit_user = create(:user, full_name: "Fip induction tutor")
    induction_coordinator_profile = create(:induction_coordinator_profile, schools: [school_cohort.school], user: sit_user)
    PrivacyPolicy.current.accept!(sit_user)
    induction_coordinator_profile
  end

  before do
    school_cohort.update! default_induction_programme: induction_programme
  end

  scenario "Adding an ECT" do
    given_i_sign_in_as_the_user_with_the_full_name "Fip induction tutor"

    when_i_report_a_new_ect_at_the_school

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_on_the_school_add_participant_completed_page participant_data[:full_name]
    and_i_confirm_has_participant_type_on_the_school_add_participant_completed_page "ECT"
  end

  scenario "Adding a mentor" do
    given_i_sign_in_as_the_user_with_the_full_name "Fip induction tutor"

    when_i_report_a_new_mentor_at_the_school

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_on_the_school_add_participant_completed_page participant_data[:full_name]
    and_i_confirm_has_participant_type_on_the_school_add_participant_completed_page "mentor"
  end

private

  def when_i_report_a_new_ect_at_the_school
    Pages::SchoolDashboardPage.loaded
                              .view_participant_details
                              .choose_to_add_an_ect_or_mentor
                              .add_ect(participant_data[:full_name], participant_data[:email], participant_data[:start_date], nil, nil, "Billy Mentor")
  end

  def when_i_report_a_new_mentor_at_the_school
    Pages::SchoolDashboardPage.loaded
                              .view_participant_details
                              .choose_to_add_an_ect_or_mentor
                              .add_mentor(participant_data[:full_name], participant_data[:email])
  end
end
