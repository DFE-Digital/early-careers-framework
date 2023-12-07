# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::ParticipantProfileSerializer do
  let(:profile) { create(:seed_ect_participant_profile, :valid) }
  let!(:induction_record) { create(:seed_induction_record, :with_induction_programme, participant_profile: profile) }

  subject { described_class.new(profile) }

  before do
    profile.participant_identity.update!(user: profile.teacher_profile.user)
  end

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq profile.id
      expect(data[:type]).to eq :participant_profile

      meta = data[:meta]
      expect(meta[:id]).to eq profile.user.id
      expect(meta[:email]).to eq profile.user.email
      expect(meta[:full_name]).to eq profile.user.full_name
      expect(meta[:trn]).to eq profile.teacher_profile.trn
      expect(meta[:roles]).to match_array profile.user.user_roles
      expect(meta[:profiles]).to match_array [profile.id]
      expect(meta[:identities]).to match_array profile.user.participant_identities.map { |i| [i.external_identifier, i.email] }

      attrs = data[:attributes]
      expect(attrs[:type]).to eq profile.type
      expect(attrs[:participant_identity_id]).to eq profile.participant_identity_id
      expect(attrs[:sparsity_uplift]).to eq profile.sparsity_uplift
      expect(attrs[:pupil_premium_uplift]).to eq profile.pupil_premium_uplift
      expect(attrs[:schedule_id]).to eq profile.schedule_id
      expect(attrs[:school_cohort_id]).to eq profile.school_cohort_id
      expect(attrs[:teacher_profile_id]).to eq profile.teacher_profile_id
      expect(attrs[:status]).to eq profile.status
      expect(attrs[:training_status]).to eq profile.training_status
      expect(attrs[:induction_start_date]).to eq profile.induction_start_date
      expect(attrs[:induction_completion_date]).to eq profile.induction_completion_date
      expect(attrs[:profile_duplicity]).to eq profile.profile_duplicity
      expect(attrs[:notes]).to eq profile.notes
      expect(attrs[:created_at]).to eq profile.created_at
      expect(attrs[:induction_records]).to match_array Archive::InductionRecordSerializer.new(profile.induction_records).serializable_hash[:data]
      expect(attrs[:participant_declarations]).to match_array Archive::ParticipantDeclarationSerializer.new(profile.participant_declarations).serializable_hash[:data]
      expect(attrs[:participant_profile_states]).to match_array Archive::ParticipantProfileStateSerializer.new(profile.participant_profile_states).serializable_hash[:data]
    end
  end
end
