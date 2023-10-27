# frozen_string_literal: true

RSpec.describe StatusTags::DeliveryPartnerParticipantStatusTag, type: :component do
  let(:component) { described_class.new participant_profile: ParticipantProfile.new }

  subject(:label) { render_inline component }

  context "The language file" do
    TrainingRecordState::RECORD_STATES.each_key do |key|
      it "includes the record_state :#{key} as a language entry" do
        expect(I18n.t("status_tags.delivery_partner_participant_status").keys).to include key.to_sym
      end
    end
  end

  I18n.t("status_tags.delivery_partner_participant_status").each do |key, value|
    context "when :#{key} is the determined state" do
      before { allow(component).to receive(:record_state).and_return(key) }
      it { is_expected.to have_text value[:label] }
      it { is_expected.to have_text Array.wrap(value[:description]).join(" ") }
    end

    it "includes :#{key} as a recognised record_state" do
      expect(TrainingRecordState::RECORD_STATES.keys).to include key.to_s
    end
  end
end
