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

  describe "#profile_dashboard_url" do
    it "returns the admin/suppliers path for admins" do
      expect(helper.profile_dashboard_url(admin_user)).to eq("http://test.host/admin/suppliers")
    end

    it "returns schools/choose-programme for induction coordinators" do
      expect(helper.profile_dashboard_url(induction_coordinator)).to eq("http://test.host/schools/choose-programme")
    end

    context "when a school has chosen a programme" do
      before do
        SchoolCohort.create!(school: school, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
      end

      it "returns schools for induction coordinators" do
        expect(helper.profile_dashboard_url(induction_coordinator)).to eq("http://test.host/schools")
      end
    end
  end
end
