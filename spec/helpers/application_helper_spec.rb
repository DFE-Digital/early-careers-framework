# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:admin_user) { create(:user, :admin) }
  let(:induction_coordinator) { create(:user, :induction_coordinator) }
  let(:school) { induction_coordinator.induction_coordinator_profile.schools.first }

  before do
    Cohort.create!(start_year: 2021)
    induction_coordinator.induction_coordinator_profile.update!(schools: [school])
  end

  describe "#profile_dashboard_path" do
    it "returns the admin/schools path for admins" do
      expect(helper.profile_dashboard_path(admin_user)).to eq("/admin/schools")
    end

    it "returns schools/choose-programme for induction coordinators" do
      expect(helper.profile_dashboard_path(induction_coordinator)).to eq("/schools/choose-programme/advisory")
    end

    context "when a school has chosen a programme" do
      before do
        SchoolCohort.create!(school: school, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
      end

      it "returns schools for induction coordinators" do
        expect(helper.profile_dashboard_path(induction_coordinator)).to eq("/schools")
      end
    end
  end
end
