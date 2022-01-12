# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantIdentity, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:participant_profiles) }
  it { is_expected.to have_many(:npq_applications) }
  it {
    is_expected.to define_enum_for(:origin).with_values(
      ecf: "ecf",
      npq: "npq",
    ).with_suffix.backed_by_column_of_type(:string)
  }
end
