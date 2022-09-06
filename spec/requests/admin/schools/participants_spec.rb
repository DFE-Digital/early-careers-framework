# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Participants", :with_default_schedules, with_feature_flags: { multiple_cohorts: "active" }, type: :request do
  let(:cohort_2021) { Cohort.current }
  let(:cohort_2022) { create(:cohort, :next) }
  let!(:schedule_2022) { create(:ecf_schedule, cohort: cohort_2022) }
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school:, cohort: cohort_2021) }
  let(:school_cohort_22) { create(:school_cohort, school:, cohort: cohort_2022) }

  let!(:ect_profile) { create :ect, school_cohort: }
  let!(:ect_profile_22) { create :ect, school_cohort: school_cohort_22 }
  let!(:mentor_profile) { create :mentor, school_cohort: }
  let!(:npq_profile) { create(:npq_participant_profile, school:) }
  let!(:unrelated_profile) { create :ect }
  let!(:withdrawn_profile_record) { create :mentor, :withdrawn_record, school_cohort: }

  before do
    sign_in admin_user

    school_cohort.update!(default_induction_programme: InductionProgramme.create!(school_cohort:,
                                                                                  training_programme: :core_induction_programme))

    school_cohort_22.update!(default_induction_programme: InductionProgramme.create!(school_cohort: school_cohort_22,
                                                                                     training_programme: :core_induction_programme))

    [ect_profile, mentor_profile, withdrawn_profile_record].each do |profile|
      Induction::Enrol.call(participant_profile: profile,
                            induction_programme: school_cohort.default_induction_programme)
    end

    Induction::Enrol.call(participant_profile: ect_profile_22,
                          induction_programme: school_cohort_22.default_induction_programme)

    withdrawn_profile_record.current_induction_record.update!(induction_status: withdrawn_profile_record.status,
                                                              training_status: withdrawn_profile_record.training_status)
  end

  describe "GET /admin/schools/:school_slug/participants" do
    it "renders the index template" do
      get "/admin/schools/#{school.slug}/participants"

      expect(response).to render_template("admin/schools/participants/index")
    end

    it "displays the school's active participants from any cohort" do
      get "/admin/schools/#{school.slug}/participants"

      expect(response.body).not_to include("No participants found for this school.")
      expect(assigns(:participant_profiles)).to include mentor_profile
      expect(assigns(:participant_profiles)).to include ect_profile
      expect(assigns(:participant_profiles)).to include ect_profile_22
      expect(assigns(:participant_profiles)).not_to include npq_profile
      expect(assigns(:participant_profiles)).not_to include unrelated_profile
      expect(assigns(:participant_profiles)).not_to include withdrawn_profile_record
    end
  end
end
