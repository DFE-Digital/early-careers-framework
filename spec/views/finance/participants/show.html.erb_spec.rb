# frozen_string_literal: true

require "rails_helper"

RSpec.describe "finance/participants/show.html.erb", :with_default_schedules do
  let(:profile) { create(:ect) }
  let(:user)    { profile.user }

  it "shows name for the identity" do
    assign :user, user

    render

    expect(rendered).to have_content(user.full_name)
  end

  context "with ECF profile" do
    let(:user)              { profile.user }
    let(:profile)           { create(:ect) }
    let!(:induction_record) { profile.current_induction_records.first }

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

    it "renders eligible for funding" do
      assign :user, user

      render

      expect(rendered).to have_content("Eligible for funding#{profile.fundable?.to_s.upcase}")
    end

    context "when there are declarations" do
      let!(:declaration) do
        create(:ect_participant_declaration, participant_profile: profile, cpd_lead_provider: induction_record.cpd_lead_provider)
      end

      it "renders declarations" do
        assign :user, user

        render

        expect(rendered).to have_content(declaration.id)
      end
    end
  end

  context "with NPQ profile" do
    let(:profile) { create(:npq_participant_profile) }
    let(:user)    { profile.user }

    it "renders needed information" do
      assign :user, user

      render

      expect(rendered).to have_content("Schedule identifier#{profile.schedule.schedule_identifier}")
      expect(rendered).to have_content("Schedule cohort#{profile.schedule.cohort.start_year}")

      expect(rendered).to have_content("Lead provider#{profile.npq_application.npq_lead_provider.name}")
      expect(rendered).to have_content("School URN#{profile.npq_application.school_urn}")

      expect(rendered).to have_content("Eligible for funding#{profile.fundable?.to_s.upcase}")

      expect(rendered).to have_content("Targeted support funding eligibility#{profile.npq_application.targeted_delivery_funding_eligibility ? 'YES' : 'NO'}")
    end
  end
end
