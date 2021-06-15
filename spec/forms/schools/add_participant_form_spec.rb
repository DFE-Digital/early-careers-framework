# frozen_string_literal: true

RSpec.describe Schools::AddParticipantForm, type: :model do
  it { is_expected.to validate_presence_of(:type).on(:type).with_message("Please select type of the new participant") }
  it { is_expected.to validate_inclusion_of(:type).in_array(described_class::TYPE_OPTIONS.keys.map(&:to_s)).on(:type) }

  it { is_expected.to validate_presence_of(:full_name).on(:details) }
  it { is_expected.to validate_presence_of(:email).on(:details) }
end
