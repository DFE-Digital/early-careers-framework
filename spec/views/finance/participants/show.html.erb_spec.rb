# frozen_string_literal: true

require "rails_helper"

RSpec.describe "finance/participants/show.html.erb" do
  context "with ECF profile" do
    let(:profile) { create(:ecf_participant_profile) }
    let(:user) { profile.user }

    it "renders schedule identifier and cohort" do
      assign :user, user

      render

      expect(rendered).to have_content("Schedule identifier#{profile.schedule.schedule_identifier}")
      expect(rendered).to have_content("Schedule cohort#{profile.schedule.cohort.start_year}")
    end
  end

  context "with NPQ profile" do
    let(:profile) { create(:npq_participant_profile) }
    let(:user) { profile.user }

    it "renders schedule identifier and cohort" do
      assign :user, user

      render

      expect(rendered).to have_content("Schedule identifier#{profile.schedule.schedule_identifier}")
      expect(rendered).to have_content("Schedule cohort#{profile.schedule.cohort.start_year}")
    end
  end
end
