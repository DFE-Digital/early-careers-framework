# frozen_string_literal: true

RSpec.describe StatusTags::DeliveryPartnerParticipantStatusTag, type: :component do
  let(:participant_profile) { create(:ect_participant_profile, induction_completion_date: Time.zone.now) }
  let(:training_record_state) { instance_double(TrainingRecordState, participant_profile:) }
  let(:component) { described_class.new(training_record_state) }

  subject { render_inline(component) }

  TrainingRecordState::RECORD_STATES.each_key do |record_state|
    it "includes the record_state :#{record_state} as a language entry" do
      allow(training_record_state).to receive(:record_state) { record_state }

      expect(component.label).to be_present

      expect(component.description).not_to be_empty
      expect(component.description).to all(be_present)

      is_expected.to have_css("p", text: component.label)

      component.description.each do |description|
        is_expected.to have_css("p", text: description)
      end
    end
  end
end
