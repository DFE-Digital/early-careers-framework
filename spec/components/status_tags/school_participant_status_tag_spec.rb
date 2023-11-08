# frozen_string_literal: true

RSpec.describe StatusTags::SchoolParticipantStatusTag, type: :component do
  let(:component) { described_class.new participant_profile: ParticipantProfile.new }

  subject(:label) { render_inline component }

  context "The language file" do
    TrainingRecordState::RECORD_STATES.each_key do |key|
      it "includes the record_state :#{key} as a language entry" do
        expect(I18n.t("status_tags.school_participant_status").keys).to include key.to_sym
      end
    end
  end

  I18n.t("status_tags.school_participant_status").each do |key, value|
    context "when :#{key} is the determined state" do
      before { allow(component).to receive(:record_state).and_return(key) }
      let(:tag_description) do
        Array.wrap(value[:description]).join("\n  ")
        .gsub("%{contact_us}", "contact us\n")
        .gsub("%{appropriate_body_name}", "Your appropriate body")
        .gsub("%{induction_completion_date}", "")
      end

      it { is_expected.to have_text value[:label] }
      it { is_expected.to have_text tag_description }
    end

    it "includes :#{key} as a recognised record_state" do
      expect(TrainingRecordState::RECORD_STATES.keys).to include key.to_s
    end
  end
end
