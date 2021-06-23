# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolBreadcrumbsHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  let(:school) { induction_coordinator.induction_coordinator_profile.schools.first }
  let!(:cohort) { create(:cohort, :current) }

  before do
    sign_in induction_coordinator
  end

  describe "#breadcrumbs" do
    context "when the induction coordinator has one school" do
      let(:induction_coordinator) { create(:user, :induction_coordinator) }

      it "returns an empty hash" do
        expect(helper.breadcrumbs).to eql({})
      end

      it "returns the school path" do
        expect(helper.breadcrumbs(school)).to eql({ school.name => schools_dashboard_path(school_id: school.slug) })
      end

      it "returns the cohort path" do
        expect(helper.breadcrumbs(school, cohort)).to(
          eql({
            school.name => schools_dashboard_path(school_id: school.slug),
            "#{cohort.display_name} cohort" => schools_cohort_path(school_id: school.slug, cohort_id: cohort.start_year),
          }),
        )
      end
    end

    context "when the induction coordinator has multiple schools" do
      let(:schools) { create_list(:school, rand(2..5)) }
      let(:induction_coordinator) { create(:user, :induction_coordinator, school_ids: schools.map(&:id)) }

      it "returns the schools index page" do
        expect(helper.breadcrumbs).to eql({ "Manage your schools" => schools_dashboard_index_path })
      end

      it "returns the school path" do
        expect(helper.breadcrumbs(school)).to(
          eql({
            "Manage your schools" => schools_dashboard_index_path,
            school.name => schools_dashboard_path(school_id: school.slug),
          }),
        )
      end

      it "returns the cohort path" do
        expect(helper.breadcrumbs(school, cohort)).to(
          eql({
            "Manage your schools" => schools_dashboard_index_path,
            school.name => schools_dashboard_path(school_id: school.slug),
            "#{cohort.display_name} cohort" => schools_cohort_path(school_id: school.slug, cohort_id: cohort.start_year),
          }),
        )
      end
    end
  end
end
