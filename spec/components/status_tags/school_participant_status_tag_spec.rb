# frozen_string_literal: true

RSpec.describe StatusTags::SchoolParticipantStatusTag, :with_training_record_state_examples, type: :component do
  let(:participant_profile) { ect_on_fip }

  let(:component) { described_class.new participant_profile: }

  subject(:label) { render_inline component }

  I18n.t("status_tags.school_participant_status").each do |key, value|
    context "when :#{key} is the determined state" do
      before { allow(component).to receive(:record_state).and_return(key) }
      it { is_expected.to have_text value[:label] }
      it { is_expected.to have_text Array.wrap(value[:description]).join("\n  ").gsub("%{contact_us}", "contact us\n") }
    end
  end
end
