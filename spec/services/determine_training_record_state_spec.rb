# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineTrainingRecordState, :with_training_record_state_examples do
  describe "#call" do
    context "when the training record is for an ECT doing ECF core induction training" do
      context "who is currently training" do
        subject { described_class.call(participant_profile: ect_on_cip_being_trained) }
        it { is_expected.to eql :is_training }
      end

      context "who has been withdrawn by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_cip_withdrawn_from_training) }
        it { is_expected.to eql :has_withdrawn_from_training }
      end

      context "who has been deferred by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_cip_having_deferred_their_training) }
        it { is_expected.to eql :has_deferred_their_training }
      end

      context "who has been withdrawn by their last school" do
        subject { described_class.call(participant_profile: ect_on_cip_withdrawn_from_programme) }
        it { is_expected.to eql :has_withdrawn_from_programme }
      end
    end

    context "when the training record is for an ECT doing ECF full induction training" do
      context "who is currently training" do
        subject { described_class.call(participant_profile: ect_on_fip_being_trained) }
        it { is_expected.to eql :is_training }
      end

      context "who has been withdrawn by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_fip_withdrawn_from_training) }
        it { is_expected.to eql :has_withdrawn_from_training }
      end

      context "who has been deferred by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_fip_having_deferred_their_training) }
        it { is_expected.to eql :has_deferred_their_training }
      end

      context "who has been withdrawn by their last school" do
        subject { described_class.call(participant_profile: ect_on_fip_withdrawn_from_programme) }
        it { is_expected.to eql :has_withdrawn_from_programme }
      end
    end
  end
end
