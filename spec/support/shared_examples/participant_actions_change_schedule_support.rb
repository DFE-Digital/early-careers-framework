# frozen_string_literal: true

RSpec.shared_examples "a participant change schedule action service" do
  it_behaves_like "a participant action service"
  let!(:extended_schedule) { create(:schedule, schedule_identifier: "ecf-september-extended-2021") }

  it "changes the schedule on user's profile" do
    expect(user_profile.reload.schedule.schedule_identifier).to eq("ecf-september-standard-2021")
    described_class.call(params: given_params)
    expect(user_profile.reload.schedule.schedule_identifier).to eq("ecf-september-extended-2021")
  end

  it "fails when the schedule is invalid" do
    params = given_params.merge({ schedule_identifier: "wibble" })
    expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
  end

  it "fails when the participant is withdrawn" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn")
    expect { described_class.call(params: given_params) }.to raise_error(ActionController::ParameterMissing)
  end

  context "when a pending declaration exists" do
    let!(:declaration) do
      start_date = user_profile.schedule.milestones.first.start_date
      declaration = create(:participant_declaration, declaration_date: start_date + 1.day, course_identifier: "ecf-induction", declaration_type: "started", cpd_lead_provider: cpd_lead_provider)
      create(:profile_declaration, participant_declaration: declaration, participant_profile: user_profile)
      declaration
    end

    it "fails when it would invalidate a valid declaration" do
      extended_schedule.milestones.each { |milestone| milestone.update!(start_date: milestone.start_date + 6.months, milestone_date: milestone.milestone_date + 6.months) }
      expect { described_class.call(params: given_params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "ignores voided declarations when changing the schedule" do
      declaration.void!
      extended_schedule.milestones.each { |milestone| milestone.update!(start_date: milestone.start_date + 6.months, milestone_date: milestone.milestone_date + 6.months) }

      described_class.call(params: given_params)
      expect(user_profile.reload.schedule.schedule_identifier).to eq("ecf-september-extended-2021")
    end
  end
end
