# frozen_string_literal: true

require "rails_helper"

RSpec.describe "finance/participants/show.html.erb" do
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
    end

    it "renders induction programme" do
      assign :user, user

      render

      expect(rendered).to have_content("Training programmeFull induction programme")
    end

    context "when the programme_type_changes_2025 feature is enabled" do
      before { FeatureFlag.activate(:programme_type_changes_2025) }

      it "renders new induction programme" do
        assign :user, user

        render

        expect(rendered).to have_content("Training programmeProvider led")
      end
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
end
