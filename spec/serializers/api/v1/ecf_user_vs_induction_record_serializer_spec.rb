# frozen_string_literal: true

require "rails_helper"

module Api::V1
  context "ECFInductionRecordSerializer versus ECFUserSerializer", :with_support_for_ect_examples do
    it "serialises a CIP ECT the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([cip_ect_only.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([cip_ect_only.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end

    it "serializes a FIP ECT the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([cip_ect_only.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([cip_ect_only.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end

    it "serializes a FIP Mentor the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([fip_mentor_only.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([fip_mentor_only.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "mentor"
    end

    it "serializes a CIP Mentor the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([cip_mentor_only.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([cip_mentor_only.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "mentor"
    end

    it "serializes a CIP ECT with registration complete the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([cip_ect_reg_complete.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([cip_ect_reg_complete.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end

    it "serializes a CIP ECT updated a year ago the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([cip_ect_updated_a_year_ago.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([cip_ect_updated_a_year_ago.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end

    it "serializes a FIP ECT transferring in the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([fip_ect_transferring_in.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([fip_ect_transferring_in.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end

    it "serializes a FIP ECT transferring out the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([fip_ect_transferring_out.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([fip_ect_transferring_out.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end

    it "serializes a FIP ECT withdrawn the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([fip_ect_withdrawn.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([fip_ect_withdrawn.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "other"
    end

    it "serializes a CIP ECT registered for the future the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([cip_ect_reg_for_future.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([cip_ect_reg_for_future.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
    end

    # the IR query filters out records without IRs so this would actually never occur
    it "serializes an NPQ only the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([npq_only.user]).serializable_hash[:data][0]
      serialised_induction_record = nil

      expect { serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([npq_only.induction_records&.latest]).serializable_hash[:data][0] }.to raise_error(NoMethodError)

      expect(serialised_induction_record).to eq nil
      expect(serialised_user).not_to eq nil
      expect(serialised_user[:attributes][:user_type]).to eq "other"
    end

    # real cases found in production

    it "serializes a FIP ECT that becomes a mentor as an ECT the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([fip_ect_then_mentor[:ect_profile].user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([fip_ect_then_mentor[:ect_profile].induction_records&.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
      expect(serialised_induction_record).to eq serialised_user
    end

    # 37 production cases
    it "serializes a FIP ECT with a different identity on some IRs using wrong_profile as an ECT the same" do
      profile = fip_ect_with_different_identity[:wrong_profile]
      serialised_user = Api::V1::ECFUserSerializer.new([profile.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([profile.induction_records.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
    end

    it "serializes a FIP ECT with a different identity on some IRs using correct_profile as an ECT the same" do
      profile = fip_ect_with_different_identity[:correct_profile]
      serialised_user = Api::V1::ECFUserSerializer.new([profile.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([profile.induction_records.filter { |ir| ir.end_date.nil? }.first]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
    end

    it "serializes a FIP ECT that has no participant_identity as an ECT the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([fip_ect_with_no_identity.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([fip_ect_with_no_identity.induction_records&.latest]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end

    it "serializes a CIP ECT with a corrupt induction record history as an ECT the same" do
      serialised_user = Api::V1::ECFUserSerializer.new([cip_ect_with_corrupt_history.user]).serializable_hash[:data][0]
      serialised_induction_record = Api::V1::ECFInductionRecordSerializer.new([cip_ect_with_corrupt_history.induction_records.filter { |ir| ir.end_date.nil? }.first]).serializable_hash[:data][0]

      expect(serialised_induction_record).not_to eq nil
      expect(serialised_induction_record).to eq serialised_user
      expect(serialised_induction_record[:attributes][:user_type]).to eq "early_career_teacher"
    end
  end
end
