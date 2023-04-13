# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::TestData", :with_default_schedules, type: :request do
  let(:admin_user) { create(:user, :admin) }

  let(:cohort) { Cohort.current }

  let!(:fip_cohort) { create(:seed_school_cohort, :fip, school: fip_school, cohort:) }
  let!(:cip_cohort) { create(:seed_school_cohort, :cip, school: cip_school, cohort:) }

  let(:fip_programme) { create(:seed_induction_programme, :valid, school_cohort: fip_cohort) }
  let(:cip_programme) { create(:seed_induction_programme, :cip, :valid, school_cohort: cip_cohort) }

  let(:fip_school) { create(:seed_school, :valid, name: "Highgate School") }
  let(:cip_school) { create(:seed_school, :valid, name: "Keefeport Infant School") }
  let!(:ytc_school) { create(:seed_school, :valid, name: "View School") }
  let!(:unclaimed_school) { create(:seed_school, :valid, name: "Southern School") }

  let!(:fip_sit) { create(:seed_induction_coordinator_profiles_school, :with_induction_coordinator_profile, school: fip_school) }
  let!(:cip_sit) { create(:seed_induction_coordinator_profiles_school, :with_induction_coordinator_profile, school: cip_school) }
  let!(:ytc_sit) { create(:seed_induction_coordinator_profiles_school, :with_induction_coordinator_profile, school: ytc_school) }

  before do
    sign_in admin_user
  end

  describe "viewing a list of schools that have selected FIP for the current cohort" do
    before do
      get "/admin/test-data/fip-schools"
    end

    it "renders the FIP schools index template" do
      expect(response).to render_template "admin/test_data/fip_schools/index"
    end

    it "only includes schools that have selected FIP" do
      expect(response.body).to include(fip_school.name)
      expect(response.body).not_to include(cip_school.name)
      expect(response.body).not_to include(ytc_school.name)
      expect(response.body).not_to include(unclaimed_school.name)
    end
  end

  describe "viewing a list of schools that have selected CIP for the current cohort" do
    before do
      get "/admin/test-data/cip-schools"
    end

    it "renders the CIP schools index template" do
      expect(response).to render_template "admin/test_data/cip_schools/index"
    end

    it "only includes schools that have selected CIP" do
      expect(response.body).not_to include(fip_school.name)
      expect(response.body).to include(cip_school.name)
      expect(response.body).not_to include(ytc_school.name)
      expect(response.body).not_to include(unclaimed_school.name)
    end
  end

  describe "viewing a list of schools that have not chosen a programme for the current cohort" do
    before do
      get "/admin/test-data/yet-to-choose-schools"
    end

    it "renders the yet_to_chose_schools index template" do
      expect(response).to render_template "admin/test_data/yet_to_choose_schools/index"
    end

    it "only includes schools that have selected CIP" do
      expect(response.body).not_to include(fip_school.name)
      expect(response.body).not_to include(cip_school.name)
      expect(response.body).to include(ytc_school.name)
      expect(response.body).not_to include(unclaimed_school.name)
    end
  end

  describe "viewing a list of unclaimed schools" do
    before do
      get "/admin/test-data/unclaimed-schools"
    end

    it "renders the unclaimed_schools index template" do
      expect(response).to render_template "admin/test_data/unclaimed_schools/index"
    end

    it "only includes schools that have no induction coordinator" do
      expect(response.body).not_to include(fip_school.name)
      expect(response.body).not_to include(cip_school.name)
      expect(response.body).not_to include(ytc_school.name)
      expect(response.body).to include(unclaimed_school.name)
    end

    it "displays a link to generate a nomination email" do
      expect(response.body).to include("Generate link")
    end

    context "when there is an unexpired NominationEmail" do
      let!(:nomination_email) { create(:seed_nomination_email, school: unclaimed_school, sent_at: 1.day.ago) }

      it "displays the nomination link" do
        get "/admin/test-data/unclaimed-schools"
        expect(response.body).to include(nomination_email.plain_nomination_url)
      end
    end
  end

  describe "generating a nomination link" do
    it "adds an new NominationEmail record for the unclaimed school" do
      expect {
        get "/admin/test-data/unclaimed-schools/#{unclaimed_school.friendly_id}/generate-link"
      }.to change { unclaimed_school.nomination_emails.count }.by 1
    end
  end
end
