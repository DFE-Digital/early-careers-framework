# frozen_string_literal: true

describe Oneoffs::NPQ::CleanupParticipantDeclaration do
  # create declaration with participant profile and participant identity
  # create second user
  # attach profile to the second user via user_id
  # run script and see that participant declaration belongs to correct user
  let(:npq_participant_declaration) { create(:npq_participant_declaration) }
  let(:user) { npq_participant_declaration.participant_profile.participant_identity.user }
  let(:npq_user) { create(:user, :npq) }

  before do
    npq_participant_declaration.update(user_id: npq_user.id)
  end

  it "reassigns records properly" do
    expect {
      described_class.new.migrate
    }.to change { npq_participant_declaration.reload.user_id }.from(npq_user.id).to(user.id)
  end
end
