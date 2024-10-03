# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::DedupeParticipant, type: :model do
  let(:npq_application) { create(:npq_application) }
  let(:trn) { npq_application.teacher_reference_number }

  let(:instance) { described_class.new(npq_application:, trn:) }

  describe "validations" do
    it { expect(instance).to be_valid }

    it { is_expected.to validate_presence_of(:npq_application) }
    it { is_expected.to validate_presence_of(:trn) }

    context "when the application TRN is not verified" do
      let(:npq_application) { create(:npq_application, teacher_reference_number_verified: false) }

      it { expect(instance).to be_invalid }
    end
  end

  context "#call" do
    subject(:call) { instance.call }

    let(:primary_user_for_trn) { travel_to(1.day.ago) { create(:teacher_profile, trn:).user } }

    it "performs an Identity::Transfer to the primary user" do
      expect(Identity::Transfer).to receive(:call).with(from_user: npq_application.user, to_user: primary_user_for_trn)

      call
    end
  end
end
