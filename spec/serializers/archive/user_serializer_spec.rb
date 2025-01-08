# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::UserSerializer do
  let(:user) { create(:seed_user, :with_teacher_profile) }
  let(:participant_identity) { create(:seed_participant_identity, user:, email: user.email) }
  let(:ect_profile) { create(:seed_ect_participant_profile, :with_schedule, :with_school_cohort, participant_identity:, teacher_profile: user.teacher_profile) }
  let!(:induction_record) { create(:seed_induction_record, :with_induction_programme, participant_profile: ect_profile, schedule: ect_profile.schedule) }

  subject { described_class.new(user) }

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq user.id
      expect(data[:type]).to eq :user

      meta = data[:meta]
      expect(meta[:id]).to eq user.id
      expect(meta[:email]).to eq user.email
      expect(meta[:full_name]).to eq user.full_name
      expect(meta[:trn]).to eq user.teacher_profile.trn
      expect(meta[:roles]).to match_array user.user_roles
      expect(meta[:profiles]).to match_array user.participant_profiles.map(&:id)
      expect(meta[:identities]).to match_array user.participant_identities.map { |i| [i.external_identifier, i.email] }

      attrs = data[:attributes]
      expect(attrs[:email]).to eq user.email
      expect(attrs[:full_name]).to eq user.full_name

      expect(attrs[:teacher_profile]).to eq Archive::TeacherProfileSerializer.new(user.teacher_profile).serializable_hash[:data]
      expect(attrs[:participant_identities]).to match_array Archive::ParticipantIdentitySerializer.new(user.participant_identities).serializable_hash[:data]
      expect(attrs[:participant_profiles]).to match_array Archive::ParticipantProfileSerializer.new(user.participant_profiles).serializable_hash[:data]
    end
  end
end
