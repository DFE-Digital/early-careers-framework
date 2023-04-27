# frozen_string_literal: true

RSpec.describe StatusTags::SchoolParticipantStatusTag, type: :component do
  let(:component) { described_class.new participant_profile: ParticipantProfile.new }

  subject(:label) { render_inline component }

  context "When the feature flag :school_participant_status_language is not active" do
    context "The language file" do
      TrainingRecordState.record_states.each_keys do |key|
        it "includes :#{key} as a language entry" do
          expect(I18n.t("status_tags.school_participant_status").keys).to include key.to_sym
        end
      end
    end

    I18n.t("status_tags.school_participant_status").each do |key, value|
      context "and :#{key} is the determined state" do
        before { allow(component).to receive(:record_state).and_return(key) }
        it { is_expected.to have_text value[:label] }
        it { is_expected.to have_text Array.wrap(value[:description]).join("\n  ").gsub("%{contact_us}", "contact us\n") }
      end
    end
  end

  context "When the feature flag :school_participant_status_language is active", with_feature_flags: { school_participant_status_language: "active" } do
    context "The language file" do
      TrainingRecordState.record_states.each_keys do |key|
        it "includes :#{key} as a language entry" do
          expect(I18n.t("status_tags.school_participant_status_detailed").keys).to include key.to_sym
        end
      end
    end

    I18n.t("status_tags.school_participant_status_detailed").each do |key, value|
      context "and :#{key} is the determined state" do
        before { allow(component).to receive(:record_state).and_return(key) }
        it { is_expected.to have_text value[:label] }
        it { is_expected.to have_selector(".govuk-tag.govuk-tag--#{value[:colour]}", exact_text: value[:label]) }
        it { is_expected.to have_text Array.wrap(value[:description]).join("\n  ").gsub("%{contact_us}", "contact us\n") }
      end
    end
  end
end
