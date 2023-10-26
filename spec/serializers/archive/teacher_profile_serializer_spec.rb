# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::TeacherProfileSerializer do
  let(:teacher_profile) { create(:seed_teacher_profile, :valid) }

  subject { described_class.new(teacher_profile) }

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq teacher_profile.id
      expect(data[:type]).to eq :teacher_profile

      attrs = data[:attributes]
      expect(attrs[:trn]).to eq teacher_profile.trn
      expect(attrs[:school_id]).to eq teacher_profile.school_id
    end
  end
end
