# frozen_string_literal: true

describe Oneoffs::NPQ::CleanupParticipantDeclaration do
  let(:npq_participant_declaration) { create(:npq_participant_declaration) }
  let(:user) { npq_participant_declaration.participant_profile.participant_identity.user }
  let(:participant_identity) { user.participant_identities.first }
  let(:npq_user) { create(:user, :npq) }

  before do
    npq_participant_declaration.update!(user_id: npq_user.id)
    participant_identity.update!(external_identifier: npq_user.id)
  end

  it "reassigns records properly" do
    expect {
      described_class.new.migrate
    }.to change { npq_participant_declaration.reload.user_id }.from(npq_user.id).to(user.id)
  end
end
