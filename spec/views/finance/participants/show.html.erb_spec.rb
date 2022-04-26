# frozen_string_literal: true

require "rails_helper"

RSpec.describe "finance/participants/show.html.erb" do
  let(:profile) { create(:ect_participant_profile) }
  let(:user) { profile.user }

  it "shows name for the identity" do
    assign :user, user

    render

    expect(rendered).to have_content(user.full_name)
  end

  context "with ECF profile" do
    let(:profile) { create(:ect_participant_profile) }
    let(:user) { profile.user }
    let(:induction_programme) { create(:induction_programme, :fip) }
    let!(:induction_record) { Induction::Enrol.call(participant_profile: profile, induction_programme: induction_programme) }

    it "renders schedule identifier and cohort" do
      assign :user, user

      render

      expect(rendered).to have_content("Schedule identifier#{profile.schedule.schedule_identifier}")
      expect(rendered).to have_content("Schedule cohort#{profile.schedule.cohort.start_year}")
    end

    it "renders induction records" do
      assign :user, user

      render

      expect(rendered).to have_content("Induction record: #{induction_record.id}")
      expect(rendered).to have_content("Training programmeFull induction programme")
    end
  end

  context "with NPQ profile" do
    let(:profile) { create(:npq_participant_profile) }
    let(:user) { profile.user }

    it "renders needed information" do
      assign :user, user

      render

      expect(rendered).to have_content("Schedule identifier#{profile.schedule.schedule_identifier}")
      expect(rendered).to have_content("Schedule cohort#{profile.schedule.cohort.start_year}")

      expect(rendered).to have_content("Lead provider#{profile.npq_application.npq_lead_provider.name}")
      expect(rendered).to have_content("School URN#{profile.npq_application.school_urn}")
    end
  end
end
