# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:finance_user) { create(:user, :finance) }
  let(:induction_coordinator) { create(:user, :induction_coordinator) }
  let(:school) { induction_coordinator.induction_coordinator_profile.schools.first }
  let!(:cohort) { create(:cohort, :current) }
  let(:participant_profile) { create(:participant_profile, :ect) }
  let(:year_2020_participant_profile) { create(:participant_profile, :ect, school_cohort: build(:school_cohort, cohort: build(:cohort, start_year: 2020))) }
  let(:participant_school) { participant_profile.school }
  let(:lead_provider) { create(:user, :lead_provider) }

  describe "#profile_dashboard_path" do
    it "returns the admin/schools path for admins" do
      expect(helper.profile_dashboard_path(admin_user)).to eq("/admin/schools")
    end

    it "returns the finance path for finance" do
      expect(helper.profile_dashboard_path(finance_user)).to eq("/finance/manage-cpd-contracts")
    end

    it "returns schools/choose-programme for induction coordinators" do
      expect(helper.profile_dashboard_path(induction_coordinator)).to eq("/schools/#{school.slug}/choose-programme")
    end

    context "when a school has chosen a programme" do
      before do
        SchoolCohort.create!(school: school, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
      end

      it "returns the school dashboard path (show)" do
        expect(helper.profile_dashboard_path(induction_coordinator)).to eq("/schools/#{school.slug}")
      end
    end

    context "when the induction coordinator has more than one school" do
      before do
        second_school = create(:school)
        induction_coordinator.induction_coordinator_profile.schools << second_school
      end

      it "return the schools dashboard path (index)" do
        expect(helper.profile_dashboard_path(induction_coordinator)).to eq("/schools")
      end
    end

    it "returns the validation start path" do
      expect(helper.profile_dashboard_path(participant_profile.user)).to eq("/participants/validation")
    end

    it "returns the no access path for NQT+1s" do
      expect(helper.profile_dashboard_path(year_2020_participant_profile.user)).to eq("/participants/no_access")
    end

    it "returns the dashboard path for lead providers" do
      expect(helper.profile_dashboard_path(lead_provider)).to eq("/dashboard")
    end
  end

  describe "#data_layer" do
    context "when the analytics data does not exist" do
      before do
        assign("data_layer", nil)
      end

      it "creates a new AnalyticsDataLayer instance" do
        analytics_data = helper.data_layer
        expect(analytics_data).to be_an_instance_of AnalyticsDataLayer
      end
    end

    context "when the analytics data exists" do
      let(:analytics_data) { AnalyticsDataLayer.new }

      before do
        assign("data_layer", analytics_data)
      end

      it "returns the current instance" do
        expect(helper.data_layer).to eq(analytics_data)
      end
    end
  end

  describe "#build_data_layer" do
    let(:school) { create(:school) }

    before do
      sign_in admin_user
      assign("school", school)
    end

    it "creates an AnalyticsDataLayer model" do
      expect(helper.build_data_layer).to be_an_instance_of AnalyticsDataLayer
    end

    it "populates the analytics data with common data" do
      data = helper.build_data_layer
      expect(data.analytics_data[:userType]).to eq("DfE admin")
      expect(data.analytics_data[:schoolId]).to eq(school.urn)
    end
  end

  describe "#service_name" do
    context "when the current path doesn't contain 'year-2020'" do
      it "displays the default service name" do
        helper.request.path = "/"
        expect(helper.service_name).to eq "Manage training for early career teachers"
      end
    end

    context "when the current path does contain 'year-2020'" do
      it "displays an NQT-oriented service name" do
        helper.request.path = start_schools_year_2020_path(school)
        expect(helper.service_name).to eq "Get support materials for NQTs"
      end
    end
  end
end
