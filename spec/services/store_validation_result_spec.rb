# frozen_string_literal: true

require "rails_helper"

RSpec.describe StoreValidationResult, :with_default_schedules do
  subject(:result) do
    described_class.call(
      participant_profile:,
      validation_data:,
      dqt_response:,
    )
  end
  let(:trn_on_profile)      { "11111" }
  let(:participant_profile) { create(:ect).tap { |pp| pp.teacher_profile.update!(trn: trn_on_profile) } }
  let!(:teacher_profile)    { participant_profile.teacher_profile }
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
        no_induction: false,
        exempt_from_induction: [true, false].sample,
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
        no_induction: false,
        exempt_from_induction: false,
      }
    end

    context "when trn returned by dqt matches the trn on the profile" do
      let(:trn_on_profile) { dqt_response[:trn] }
      before do
        participant_profile.teacher_profile.update!(trn: trn_on_profile)
      end

      it "stores participant eligibility without different_trn flag" do
        result

        expect(StoreParticipantEligibility).to have_received(:call).with(
          participant_profile:,
          eligibility_options: {
            qts: dqt_response[:qts],
            active_flags: dqt_response[:active_alert],
            previous_participation: dqt_response[:previous_participation],
            previous_induction: dqt_response[:previous_induction],
            no_induction: dqt_response[:no_induction],
            exempt_from_induction: dqt_response[:exempt_from_induction],
            different_trn: false,
          },
        )
      end

      context "when another teacher profile exists with the same trn number" do
        let!(:older_teacher_profile) { create(:teacher_profile, trn: dqt_response[:trn]) }

        it "transfers the participant identity onto the previous record" do
          expect { result }
            .to change { participant_profile.reload.teacher_profile }.from(teacher_profile).to(older_teacher_profile)
        end
      end
    end

    context "when trn returned by dqt does not match the trn on the profile" do
      it "stores participant eligibility with different_trn flag" do
        result

        expect(StoreParticipantEligibility).to have_received(:call).with(
          participant_profile:,
          eligibility_options: {
            qts: dqt_response[:qts],
            active_flags: dqt_response[:active_alert],
            previous_participation: dqt_response[:previous_participation],
            previous_induction: dqt_response[:previous_induction],
            no_induction: dqt_response[:no_induction],
            exempt_from_induction: dqt_response[:exempt_from_induction],
            different_trn: true,
          },
        )
      end

      context "when another teacher profile exists with the same trn number" do
        let!(:older_teacher_profile) { create(:teacher_profile, trn: dqt_response[:trn]) }

        it "does not transfers the participant identity onto the previous record" do
          expect { result }.not_to change { participant_profile.reload.teacher_profile }
        end
      end
    end

    context "when no trn is stored against the profile yet" do
      let(:trn_on_profile) { nil }

      it "stores participant eligibility without different_trn flag" do
        result

        expect(StoreParticipantEligibility).to have_received(:call).with(
          participant_profile:,
          eligibility_options: {
            qts: dqt_response[:qts],
            active_flags: dqt_response[:active_alert],
            previous_participation: dqt_response[:previous_participation],
            previous_induction: dqt_response[:previous_induction],
            no_induction: dqt_response[:no_induction],
            exempt_from_induction: dqt_response[:exempt_from_induction],
            different_trn: false,
          },
        )
      end

      it "synchronizes the trn on profile with the one returned by dqt" do
        expect { result }.to change { teacher_profile.reload.trn }.to dqt_response[:trn]
      end

      context "when another teacher profile exists with the same trn number" do
        let!(:older_teacher_profile) { create(:teacher_profile, trn: dqt_response[:trn]) }

        it "transfers the participant identity onto the previous record" do
          expect { result }
            .to change { participant_profile.reload.teacher_profile }.from(teacher_profile).to(older_teacher_profile)
        end
      end
    end
  end
end
