# frozen_string_literal: true

RSpec.describe StatusTags::DeliveryPartnerParticipantStatusTag, :with_training_record_state_examples, type: :component do
  let(:participant_profile) { create :seed_ect_participant_profile }

  let(:component) { described_class.new participant_profile: }

  subject(:label) { render_inline component }

  I18n.t("status_tags.delivery_partner_participant_status").each do |key, value|
    context "when :#{key} is the determined state" do
      before { allow(component).to receive(:record_state).and_return(key) }
      it { is_expected.to have_text value[:label] }
      it { is_expected.to have_text Array.wrap(value[:description]) }
    end
  end
end
