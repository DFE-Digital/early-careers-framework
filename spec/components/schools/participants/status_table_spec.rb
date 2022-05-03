# frozen_string_literal: true

RSpec.describe Schools::Participants::StatusTable, type: :view_component do
  let!(:participant_profile) { create(:ecf_participant_profile, :ecf_participant_eligibility, school_cohort: school_cohort) }
  let(:cip) { create(:core_induction_programme) }
  let!(:school_cohort) { create :school_cohort, :fip }
  let!(:partnership) { create :partnership, school: school_cohort.school, cohort: school_cohort.cohort }

  component { described_class.new participant_profiles: [participant_profile], school_cohort: participant_profile.school_cohort }

  stub_component Schools::Participants::StatusTableRow

  context "participant is on fip" do
    let(:programme) { create(:induction_programme, :fip) }

    before do
      Induction::Enrol.call(participant_profile: participant_profile, induction_programme: programme)
    end

    context "eligible" do
      it "renders table row" do
        expect(rendered).to have_rendered(Schools::Participants::StatusTableRow).with(profile: participant_profile)
        expect(rendered).to have_css("th", text: "Name")
        expect(rendered).to have_css("th", text: "Lead provider")
        expect(rendered).to have_css("th", text: "Delivery partner")
        expect(rendered).to have_css("th", text: "Start term")
      end
    end

    context "ineligible" do
      it "renders table row" do
        participant_profile.ecf_participant_eligibility.update!(status: "ineligible", previous_induction: true)

        expect(rendered).to have_rendered(Schools::Participants::StatusTableRow).with(profile: participant_profile)
        expect(rendered).to have_css("th", text: "Name")
        expect(rendered).to have_css("th", text: "Action required")
      end
    end
  end

  context "participant is on cip" do
    let(:programme) { create(:induction_programme, :cip) }

    before do
      participant_profile.school_cohort.update!(induction_programme_choice: "core_induction_programme",
                                                core_induction_programme: cip)
      Induction::Enrol.call(participant_profile: participant_profile, induction_programme: programme)
    end

    context "eligible" do
      it "renders table row" do
        expect(rendered).to have_rendered(Schools::Participants::StatusTableRow).with(profile: participant_profile)
        expect(rendered).to have_css("th", text: "Name")
        expect(rendered).to have_css("th", text: "Materials supplier")
        expect(rendered).to have_css("th", text: "Start term")
      end
    end
  end
end
