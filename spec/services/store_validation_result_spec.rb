# frozen_string_literal: true

require "rails_helper"

RSpec.describe StoreValidationResult do
  subject(:result) do
    described_class.call(
      participant_profile: participant_profile,
      validation_data: validation_data,
      dqt_response: dqt_response,
    )
  end

  let(:trn_on_profile) { "11111" }
  let(:teacher_profile) { create(:teacher_profile, trn: trn_on_profile) }
  let(:participant_profile) { create(:participant_profile, :ect, teacher_profile: teacher_profile) }

  let(:validation_data) do
    {
      trn: "1234567",
      full_name: "Karen Hastings",
      date_of_birth: Date.new(1993, 11, 16),
      nino: "QQ123456A",
    }
  end

  let(:dqt_response) do
    [
      nil,
      {
        trn: "1234567",
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
      },
    ].sample
  end

  let(:manual_check_record) { create(:ecf_participant_eligibility, :manual_check) }
  let(:eligible_record) { create(:ecf_participant_eligibility, :eligible) }

  before do
    allow(StoreParticipantEligibility).to receive(:call)
  end

  it "stores the validation record in the database" do
    expect { result }
      .to change { participant_profile.reload.ecf_participant_validation_data }
      .from(nil)
      .to(instance_of(ECFParticipantValidationData))

    expect(participant_profile.ecf_participant_validation_data).to have_attributes(
      trn: validation_data[:trn],
      full_name: validation_data[:full_name],
      date_of_birth: validation_data[:dob],
      nino: validation_data[:nino],
    )
  end

  context "when a dqt response is present" do
    let(:dqt_response) do
      {
        trn: "1234567",
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
      }
    end

    context "when trn returned by dqt matches the trn on the profile" do
      let(:trn_on_profile) { dqt_response[:trn] }

      it "stores participant eligibility without different_trn flag" do
        result

        expect(StoreParticipantEligibility).to have_received(:call).with(
          participant_profile: participant_profile,
          eligibility_options: {
            qts: dqt_response[:qts],
            active_flags: dqt_response[:active_alert],
            previous_participation: dqt_response[:previous_participation],
            previous_induction: dqt_response[:previous_induction],
            different_trn: false,
          },
        )
      end
    end

    context "when trn returned by dqt does not match the trn on the profile" do
      it "stores participant eligibility with different_trn flag" do
        result

        expect(StoreParticipantEligibility).to have_received(:call).with(
          participant_profile: participant_profile,
          eligibility_options: {
            qts: dqt_response[:qts],
            active_flags: dqt_response[:active_alert],
            previous_participation: dqt_response[:previous_participation],
            previous_induction: dqt_response[:previous_induction],
            different_trn: true,
          },
        )
      end
    end

    context "when no trn is stored against the profile yet" do
      let(:trn_on_profile) { nil }

      it "stores participant eligibility without different_trn flag" do
        result

        expect(StoreParticipantEligibility).to have_received(:call).with(
          participant_profile: participant_profile,
          eligibility_options: {
            qts: dqt_response[:qts],
            active_flags: dqt_response[:active_alert],
            previous_participation: dqt_response[:previous_participation],
            previous_induction: dqt_response[:previous_induction],
            different_trn: false,
          },
        )
      end

      it "synchronizes the trn on profile with the one returned by dqt" do
        expect { result }.to change { teacher_profile.reload.trn }.to dqt_response[:trn]
      end
    end
  end
end
