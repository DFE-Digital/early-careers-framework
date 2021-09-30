# frozen_string_literal: true

require "rails_helper"

RSpec.describe ECFParticipantValidationData, type: :model do
  it { is_expected.to belong_to(:participant_profile) }

  it "updates the updated_at on the User" do
    freeze_time
    profile = create(:participant_profile, :ect)
    user = profile.user
    validation_data = profile.create_ecf_participant_validation_data!(trn: "1234567", full_name: "Gordon Banks")
    user.update!(updated_at: 2.weeks.ago)
    validation_data.touch
    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
  end
end
