# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:induction_coordinator) { create(:user, :induction_coordinator) }
  let(:school) { induction_coordinator.induction_coordinator_profile.schools.first }
  let!(:cohort) { create(:cohort, :current) }

  describe "#profile_dashboard_path" do
    it "returns the admin/schools path for admins" do
      expect(helper.profile_dashboard_path(admin_user)).to eq("/admin/schools")
    end

    it "returns schools/choose-programme for induction coordinators" do
      expect(helper.profile_dashboard_path(induction_coordinator)).to eq("/schools/#{school.slug}/choose-programme/advisory")
    end

    context "when a school has chosen a programme" do
      before do
        SchoolCohort.create!(school: school, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
      end

      it "returns the school dashboard path (show)" do
        expect(helper.profile_dashboard_path(induction_coordinator)).to eq("/schools/#{school.slug}")
      end
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
end
