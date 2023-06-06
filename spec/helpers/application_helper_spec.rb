# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:induction_coordinator) { create(:user, :induction_coordinator) }
  let(:school) { induction_coordinator.induction_coordinator_profile.schools.first }
  let(:participant_profile) { create(:ect) }

  let!(:cohort) { Cohort.current || create(:cohort, :current) }

  describe "#induction_coordinator_dashboard_path" do
    it "returns schools/choose-programme for induction coordinators" do
      expect(helper.induction_coordinator_dashboard_path(induction_coordinator)).to eq("/schools/#{school.slug}/cohorts/#{cohort.start_year}/setup")
    end

    context "when a school has chosen a programme" do
      before do
        SchoolCohort.create!(school:, cohort:, induction_programme_choice: "full_induction_programme")
      end

      it "returns the school dashboard path (show)" do
        expect(helper.induction_coordinator_dashboard_path(induction_coordinator)).to eq("/schools/#{school.slug}#_#{cohort.description.parameterize}")
      end

      context "when a new registration cohort is active", travel_to: Time.current + 3.years do
        let(:future_cohort) do
          create(:cohort,
                 start_year: Time.current.year,
                 registration_start_date: Time.current - 1.day)
        end

        before do
          pilot!(school)
          SchoolCohort.create!(school:, cohort: future_cohort, induction_programme_choice: "full_induction_programme")
        end

        it "returns the school dashboard path with the active registration tab selected" do
          expect(helper.induction_coordinator_dashboard_path(induction_coordinator))
            .to eq("/schools/#{school.slug}##{TabLabelDecorator.new(future_cohort.description).parameterize}")
        end
      end
    end

    context "when the induction coordinator has more than one school" do
      before do
        second_school = create(:school)
        induction_coordinator.induction_coordinator_profile.schools << second_school
      end

      it "return the schools dashboard path (index)" do
        expect(helper.induction_coordinator_dashboard_path(induction_coordinator)).to eq("/schools")
      end
    end
  end

  describe "#participant_start_path" do
    it "returns the validation start path", :with_default_schedules do
      expect(helper.participant_start_path(participant_profile.user)).to eq("/participants/validation")
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
    it "displays the default service name" do
      helper.request.path = "/"
      expect(helper.service_name).to eq "Manage training for early career teachers"
    end
  end
end
