# frozen_string_literal: true

RSpec.describe "rake eligibility:re_run_ect_validations", type: :task do
  let(:eligible_validation_result) do
    {
      previous_participation: false,
      previous_induction: false,
      qts: true,
      different_trn: false,
      active_flags: false,
    }
  end

  before do
    allow(ParticipantValidationService).to receive(:validate).and_return(eligible_validation_result)
  end

  it "re runs validations on all eligible ects last validated after the specified timestamp" do
    timestamp = 1.hour.ago
    eligible_ects = nil
    ineligible_ect = nil
    eligible_ect_created_after_specified_time = nil

    travel_to(timestamp - 1.hour) do
      eligible_ects = create_eligible_ects(count: 2)
      ineligible_ect = create_ineligible_ects(count: 1).first
    end

    travel_to(timestamp + 30.minutes) do
      eligible_ect_created_after_specified_time = create_eligible_ects(count: 1)
    end

    expect(Participants::ParticipantValidationForm).to receive(:call).once.with(eligible_ects.first).and_call_original
    expect(Participants::ParticipantValidationForm).to receive(:call).once.with(eligible_ects.last).and_call_original
    expect(Participants::ParticipantValidationForm).to_not receive(:call).with(ineligible_ect)
    expect(Participants::ParticipantValidationForm).to_not receive(:call).with(eligible_ect_created_after_specified_time)

    capture_output { 2.times { task.execute(to_task_arguments(timestamp.to_i)) } }
  end

  def create_eligible_ects(count:)
    count.times.map do
      create(:ect_participant_profile).tap do |profile|
        create(:ecf_participant_validation_data, trn: profile.teacher_profile.trn)
        create(:ecf_participant_eligibility, :eligible, participant_profile: profile)
      end
    end
  end

  def create_ineligible_ects(count:)
    count.times.map do
      create(:ect_participant_profile, :ecf_participant_validation_data).tap do |profile|
        create(:ecf_participant_eligibility, :ineligible, participant_profile: profile)
      end
    end
  end
end
