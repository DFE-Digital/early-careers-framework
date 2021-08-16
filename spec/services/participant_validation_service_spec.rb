# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantValidationService do
  describe "#validate" do
    let(:trn) { "1234567" }
    let(:nino) { "QQ123456A" }
    let(:full_name) { "John Smith" }
    let(:dob) { Date.new(1970, 1, 2) }
    let(:qts_date) { 6.weeks.ago.to_date }
    let(:alert) { false }
    let(:dqt_record) do
      { teacher_reference_number: trn,
        national_insurance_number: nino,
        full_name: full_name,
        date_of_birth: dob,
        qts_date: qts_date,
        active_alert: alert }
    end
    let(:validation_result) { ParticipantValidationService.validate(trn: trn, nino: nino, full_name: full_name, date_of_birth: dob) }

    it "calls show on the DQT API client" do
      expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).with(
        { params: { teacher_reference_number: trn, national_insurance_number: nino } },
      )

      ParticipantValidationService.validate(trn: trn, nino: nino, full_name: full_name, date_of_birth: dob)
    end

    context "when the participant cannot be found" do
      before do
        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).and_return(nil)
      end

      it "returns nil" do
        expect(validation_result).to eql nil
      end
    end

    context "when trn is less than 7 characters" do
      let(:trn) { "123456" }
      let(:padded_trn) { "0123456" }

      let(:dqt_record) do
        { teacher_reference_number: "0123456", # API sends padded TRNs
          national_insurance_number: nino,
          full_name: full_name,
          date_of_birth: dob,
          qts_date: qts_date,
          active_alert: alert }
      end

      let(:validation_result) do
        ParticipantValidationService.validate(
          trn: trn,
          nino: "WRONG",
          full_name: full_name,
          date_of_birth: dob,
        )
      end

      before do
        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).and_return(dqt_record)
      end

      it "returns record with padded trn when trn is not padded" do
        expect(validation_result).to eql({ trn: padded_trn, qts: true, active_alert: false })
      end
    end

    context "when the participant has qts and no active flags" do
      before do
        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).and_return(dqt_record)
      end

      it "returns true when all fields match" do
        expect(validation_result).to eql({ trn: trn, qts: true, active_alert: false })
      end

      it "returns the validated details when date of birth is wrong" do
        expect(
          ParticipantValidationService.validate(trn: trn, nino: nino, full_name: full_name, date_of_birth: Date.new(1980, 1, 2)),
        ).to eql({ trn: trn, qts: true, active_alert: false })
      end

      it "returns the validated details when name is wrong" do
        expect(
          ParticipantValidationService.validate(trn: trn, nino: nino, full_name: "John Smithe", date_of_birth: dob),
        ).to eql({ trn: trn, qts: true, active_alert: false })
      end

      it "returns the validated details when nino is wrong" do
        expect(
          ParticipantValidationService.validate(trn: trn, nino: "AA654321A", full_name: full_name, date_of_birth: dob),
        ).to eql({ trn: trn, qts: true, active_alert: false })
      end

      it "returns the validated details when name is wrong and nino is cased differently" do
        expect(
          ParticipantValidationService.validate(trn: trn, nino: nino.downcase, full_name: "John Smithe", date_of_birth: dob),
        ).to eql({ trn: trn, qts: true, active_alert: false })
      end
    end

    context "when 3 of 4 things match and only first name matches" do
      let(:validation_result) do
        ParticipantValidationService.validate(
          trn: trn,
          nino: "WRONG",
          full_name: full_name.split(" ").first.to_s,
          date_of_birth: dob,
        )
      end

      it "returns nil" do
        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).and_return(dqt_record, nil)

        expect(validation_result).to be_nil
      end

      context "when config check_first_name_only: true" do
        let(:validation_result) do
          ParticipantValidationService.validate(
            trn: trn,
            nino: "WRONG",
            full_name: full_name.split(" ").first.to_s,
            date_of_birth: dob,
            config: { check_first_name_only: true },
          )
        end

        it "returns validated details" do
          expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).and_return(dqt_record)

          expect(validation_result).to eql({ trn: trn, qts: true, active_alert: false })
        end
      end
    end

    context "when the wrong trn is provided" do
      let(:other_trn) { "7654321" }
      before do
        record_for_other_trn = { teacher_reference_number: other_trn,
                                 national_insurance_number: "AA654321A",
                                 full_name: "John Smithe",
                                 date_of_birth: Date.new(1990, 2, 1),
                                 qts_date: qts_date,
                                 active_alert: alert }

        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show)
                                                             .twice
                                                             .and_return(record_for_other_trn, dqt_record)
      end

      it "returns the correct details" do
        expect(ParticipantValidationService.validate(
                 trn: other_trn,
                 nino: nino,
                 full_name: full_name,
                 date_of_birth: dob,
               )).to eql({ trn: trn, qts: true, active_alert: false })
      end
    end

    context "when the participant has no QTS" do
      let(:qts_date) { nil }
      before do
        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).and_return(dqt_record)
      end

      it "returns correct QTS information" do
        expect(validation_result).to eql({ trn: trn, qts: false, active_alert: false })
      end
    end

    context "when the participant has an active alert" do
      let(:alert) { true }
      before do
        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).and_return(dqt_record)
      end

      it "returns returns the correct alert details" do
        expect(validation_result).to eql({ trn: trn, qts: true, active_alert: true })
      end
    end

    context "when the DQT nino is blank" do
      let(:nino) { "" }
      before do
        expect_any_instance_of(Dqt::Api::V1::DQTRecord).to receive(:show).twice.and_return(dqt_record)
      end

      it "does not count blank NINos as matching" do
        expect(ParticipantValidationService.validate(trn: trn, nino: "", full_name: "John Smithe", date_of_birth: dob)).to be_nil
      end
    end
  end
end
