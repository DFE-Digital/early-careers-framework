# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantValidationService do
  before do
    create(:cohort, :current)
  end

  describe "#validate" do
    let(:trn) { "1234567" }
    let(:nino) { "QQ123456A" }
    let(:full_name) { "John Smith" }
    let(:dob) { Date.new(1970, 1, 2) }
    let(:qts_date) { 6.weeks.ago.to_date }
    let(:qts) do
      {
        "name" => "Qualified teacher (trained)",
        "qts_date" => qts_date,
        "state" => 0,
        "state_name" => "Active",
      }
    end
    let(:alert) { false }
    let(:induction_start_date) { Date.parse("2021-07-01T00:00:00Z") }
    let(:induction_completion_date) { Date.parse("2021-07-05T00:00:00Z") }
    let(:induction) { nil }
    let(:inactive_record) { false }
    let(:dqt_record) { build_dqt_record(trn:, nino:, full_name:, dob:, alert:, qts:, induction:, inactive: inactive_record) }
    let(:dqt_records) { [dqt_record] }

    let(:validation_result) { ParticipantValidationService.validate(trn:, nino:, full_name:, date_of_birth: dob) }

    it "calls get_record on the DQT API client" do
      expect_any_instance_of(FullDQT::Client).to receive(:get_record).with({ trn:, birthdate: dob, nino: })

      validation_result
    end

    context "when neither trn nor nino is provided" do
      let(:trn) { nil }
      let(:nino) { nil }

      it "returns nil" do
        expect(validation_result).to be_nil
      end
    end

    context "when trn is not provided, but nino is" do
      let(:trn) { nil }

      it "queries dqt with fake trn" do
        expect_any_instance_of(FullDQT::Client).to receive(:get_record).with({ trn: "0000001", birthdate: dob, nino: })
        validation_result
      end
    end

    context "given that it calls the API" do
      before do
        expect_any_instance_of(FullDQT::Client).to receive(:get_record).and_return(*dqt_records)
      end

      context "when the participant cannot be found" do
        let(:dqt_records) { [nil] }

        it "returns nil" do
          expect(validation_result).to eql nil
        end
      end

      context "when an inactive record is returned" do
        let(:inactive_record) { true }

        it "returns nil" do
          expect(validation_result).to be_nil
        end
      end

      context "when trn is less than 7 characters" do
        let(:trn) { "0123456" }
        let(:entered_trn) { "123456" }

        let(:validation_result) do
          ParticipantValidationService.validate(
            trn: entered_trn,
            nino: "WRONG",
            full_name:,
            date_of_birth: dob,
          )
        end

        it "returns record with padded trn when trn is not padded" do
          expect(validation_result).to eql(build_validation_result(trn:))
        end
      end

      context "when the participant has qts and no active flags" do
        it "returns true when all fields match" do
          expect(validation_result).to eql(build_validation_result(trn:))
        end

        it "returns the validated details when date of birth is wrong" do
          expect(
            ParticipantValidationService.validate(trn:, nino:, full_name:, date_of_birth: Date.new(1980, 1, 2)),
          ).to eql(build_validation_result(trn:))
        end

        it "returns the validated details when name is wrong" do
          expect(
            ParticipantValidationService.validate(trn:, nino:, full_name: "Johnne Smithe", date_of_birth: dob),
          ).to eql(build_validation_result(trn:))
        end

        it "returns the validated details when nino is wrong" do
          expect(
            ParticipantValidationService.validate(trn:, nino: "AA654321A", full_name:, date_of_birth: dob),
          ).to eql(build_validation_result(trn:))
        end

        it "returns the validated details when name is wrong and nino is cased differently" do
          expect(
            ParticipantValidationService.validate(trn:, nino: nino.downcase, full_name: "Johnne Smithe", date_of_birth: dob),
          ).to eql(build_validation_result(trn:))
        end

        it "returns validated details when the name is cased differently and the nino is missing" do
          expect(
            ParticipantValidationService.validate(trn:, nino: "", full_name: "JoHN SMITH", date_of_birth: dob),
          ).to eql(build_validation_result(trn:))
        end
      end

      context "when 3 of 4 things match and only first name matches" do
        let(:validation_result) do
          ParticipantValidationService.validate(
            trn:,
            nino: "WRONG",
            full_name: full_name.split(" ").first.to_s,
            date_of_birth: dob,
          )
        end
        let(:dqt_records) { [dqt_record, nil] }

        it "returns nil" do
          expect(validation_result).to be_nil
        end

        context "when config check_first_name_only: true" do
          let(:validation_result) do
            ParticipantValidationService.validate(
              trn:,
              nino: "WRONG",
              full_name: full_name.split(" ").first.to_s,
              date_of_birth: dob,
              config: { check_first_name_only: true },
            )
          end
          let(:dqt_records) { [dqt_record] }

          it "returns validated details" do
            expect(validation_result).to eql(build_validation_result(trn:))
          end
        end
      end

      context "when the wrong trn is provided" do
        let(:other_trn) { "7654321" }
        let(:record_for_other_trn) do
          build_dqt_record(trn: other_trn,
                           nino: "AA654321A",
                           full_name: "Jenny Mathews",
                           dob: Date.new(1990, 2, 1),
                           alert: false,
                           qts: nil,
                           induction: nil)
        end
        let(:dqt_records) { [record_for_other_trn, dqt_record] }

        it "returns the correct details" do
          expect(ParticipantValidationService.validate(
                   trn: other_trn,
                   nino:,
                   full_name:,
                   date_of_birth: dob,
                 )).to eql(build_validation_result(trn:))
        end
      end

      context "when the participant has no QTS" do
        let(:qts_date) { nil }

        it "returns correct QTS information" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { qts: false }))
        end
      end

      context "when the participant has an active alert" do
        let(:alert) { true }

        it "returns returns the correct alert details" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { active_alert: true }))
        end
      end

      context "when the DQT nino is blank" do
        let(:nino) { "" }
        let(:dqt_records) { [dqt_record, nil] }

        it "does not count blank NINos as matching" do
          expect(ParticipantValidationService.validate(trn:, nino: "", full_name: "John Smithe", date_of_birth: dob)).to be_nil
        end
      end

      context "when the participant has previously participated" do
        let!(:eligibility) { create(:ineligible_participant, trn:, reason: :previous_induction_and_participation) }

        it "returns returns the correct previous_participation flags" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { previous_participation: true }))
        end
      end

      context "when the participant has previously had an induction" do
        let(:induction) do
          {
            "start_date" => induction_start_date,
            "completion_date" => induction_completion_date,
            "status" => "Pass",
            "state" => 0,
            "state_name" => "Active",
          }
        end

        it "returns returns the correct previous_participation flags" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, no_induction: false }))
        end
      end

      context "when the participant has an induction with nil start_date" do
        let(:induction) do
          {
            "start_date" => nil,
          }
        end

        it "does not raise an error" do
          expect { validation_result }.not_to raise_error
        end

        it "returns previous_induction as false" do
          expect(validation_result[:previous_induction]).to eq false
        end

        it "returns no_induction as true" do
          expect(validation_result[:no_induction]).to eq true
        end
      end

      context "when the participant has previously had an induction and participation" do
        let!(:eligibility) { create(:ineligible_participant, trn:, reason: :previous_participation) }
        let(:induction) do
          {
            "start_date" => induction_start_date,
            "completion_date" => induction_completion_date,
            "status" => "Pass",
            "state" => 0,
            "state_name" => "Active",
          }
        end

        it "returns returns both flags" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, previous_participation: true, no_induction: false }))
        end
      end

      context "when the participant has an induction start date in or after September this year" do
        let(:induction_start_date) { Time.zone.parse("2021-09-01T00:00:00Z") }
        let(:induction_completion_date) { nil }
        let(:induction) do
          {
            "start_date" => induction_start_date,
            "completion_date" => induction_completion_date,
            "status" => "Pass",
            "state" => 0,
            "state_name" => "Active",
          }
        end

        it "returns false for previous induction" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: false, no_induction: false }))
        end
      end

      context "when the participant has an induction start date is exactly on the threshold" do
        let(:induction_start_date) { Time.zone.parse("2021-08-31T23:00:00Z") }
        let(:induction_completion_date) { nil }
        let(:induction) do
          {
            "start_date" => induction_start_date,
            "completion_date" => induction_completion_date,
            "status" => "Pass",
            "state" => 0,
            "state_name" => "Active",
          }
        end

        it "returns false for previous induction and parses timezones correctly" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: false, no_induction: false }))
        end
      end

      context "when the participant has an induction start date before September 2021" do
        let(:induction_start_date) { Time.zone.parse("2021-08-31T22:59:59Z") }
        let(:induction_completion_date) { nil }
        let(:induction) do
          {
            "start_date" => induction_start_date,
            "completion_date" => induction_completion_date,
            "status" => "Pass",
            "state" => 0,
            "state_name" => "Active",
          }
        end

        it "returns true for previous induction" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, no_induction: false }))
        end
      end

      context "when the participant has an induction with the status of 'Exempt'" do
        let(:induction) do
          {
            "start_date" => nil,
            "completion_date" => nil,
            "status" => "Exempt",
            "state" => 0,
            "state_name" => "Exempt",
          }
        end

        it "sets exempt_from_induction to true" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { exempt_from_induction: true, no_induction: true }))
        end
      end
    end
  end

  def build_validation_result(trn:, options: {})
    {
      trn:,
      qts: true,
      active_alert: false,
      previous_participation: false,
      previous_induction: false,
      no_induction: true,
      exempt_from_induction: false,
    }.merge(options)
  end

  def build_dqt_record(trn:, nino:, full_name:, dob:, alert:, qts:, induction:, inactive: false)
    {
      "trn" => trn,
      "ni_number" => nino,
      "name" => full_name,
      "dob" => dob,
      "active_alert" => alert,
      "state" => (inactive ? 1 : 0),
      "state_name" => (inactive ? "Inactive" : "Active"),
      "qualified_teacher_status" => qts,
      "induction" => induction,
      "initial_teacher_training" => {
        "programme_start_date" => "2021-06-27T00:00:00Z",
        "programme_end_date" => "2021-07-04T00:00:00Z",
        "programme_type" => "Overseas Trained Teacher Programme",
        "result" => "Pass",
        "subject1" => "applied biology",
        "subject2" => "applied chemistry",
        "subject3" => "applied computing",
        "qualification" => "BA (Hons)",
        "state" => 0,
        "state_name" => "Active",
      },
      "qualifications" => [
        {
          "name" => "Higher Education",
          "date_awarded" => nil,
        },
        {
          "name" => "NPQH",
          "date_awarded" => "2021-07-05T00:00:00Z",
        },
        {
          "name" => "Mandatory Qualification",
          "date_awarded" => nil,
        },
        {
          "name" => "HLTA",
          "date_awarded" => nil,
        },
        {
          "name" => "NPQML",
          "date_awarded" => "2021-07-05T00:00:00Z",
        },
        {
          "name" => "NPQSL",
          "date_awarded" => "2021-07-04T00:00:00Z",
        },
        {
          "name" => "NPQEL",
          "date_awarded" => "2021-07-04T00:00:00Z",
        },
      ],
    }
  end
end
