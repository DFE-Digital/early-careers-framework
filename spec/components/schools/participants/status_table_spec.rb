# frozen_string_literal: true

RSpec.describe Schools::Participants::StatusTable, type: :view_component do
  let!(:participant_profile) { create(:ecf_participant_profile) }
  let(:cip) { create(:core_induction_programme) }
  let(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible) }
  let!(:ineligible_participant_profile) { create(:ecf_participant_profile, ecf_participant_eligibility: ecf_participant_eligibility) }

  component { described_class.new participant_profiles: ParticipantProfile.all, school_cohort: participant_profile.school_cohort }

  stub_component Schools::Participants::StatusTableRow

  it "renders table row for each participant profile on the page" do
    expect(rendered).to have_rendered(Schools::Participants::StatusTableRow).with(profile: participant_profile)
  end

  it "renders table row for each ineligible participant profile on the page" do
    expect(rendered).to have_rendered(Schools::Participants::StatusTableRow).with(profile: participant_profile)
  end

  before do
    participant_profile.school_cohort.update!(induction_programme_choice: "core_induction_programme",
                                              core_induction_programme: cip)
  end

  it "renders table row for participant on cip" do
    expect(rendered).to have_rendered(Schools::Participants::StatusTableRow).with(profile: participant_profile)
  end
end
