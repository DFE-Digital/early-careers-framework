# frozen_string_literal: true

RSpec.describe ParticipantStatusTagComponent, type: :component do
  let!(:participant_profile) { create :ect_participant_profile }
  let(:component) { described_class.new profile: participant_profile }
  subject { page }

  before { render_inline(component) }

  it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Training") }
end
