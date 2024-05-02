# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantValidationService do
  before do
    create(:cohort, :current)
  end

  describe "#validate" do
    let(:trn) { "1234567" }
    let(:nino) { "QQ123456A" }
    let(:first_name) { "John" }
    let(:last_name) { "Smith" }
    let(:full_name) { [first_name, last_name].join(" ") }
    let(:dob) { Date.new(1970, 1, 2) }
    let(:qts_date) { 6.weeks.ago.to_date }
    let(:qts) do
      {
        "awarded" => qts_date,
        "statusDescription" => "Active",
      }
    end
    let(:alert) { false }
    let(:induction_start_date) { Date.parse("2021-07-01T00:00:00Z") }
    let(:induction_completion_date) { Date.parse("2021-07-05T00:00:00Z") }
    let(:induction) { { "periods" => [{ "startDate" => nil }] } }
    let(:inactive_record) { false }
    let(:induction) { nil }
    let(:dqt_record) do
      {
        "trn" => trn,
        "nationalInsuranceNumber" => nino,
        "firstName" => first_name,
        "lastName" => last_name,
        "dateOfBirth" => dob,
        "qts" => qts,
        "induction" => induction,
        "alerts" => alert ? %w[Alert] : [],
      }
    end

    let(:check_service) { instance_double(DQTRecordCheck) }
    let(:presented_dqt_record) { DQTRecordPresenter.new(dqt_record) }
    let(:check_result) { DQTRecordCheck::CheckResult.new(presented_dqt_record, true, true, true, true, 4, nil) }
    let(:no_result) { DQTRecordCheck::CheckResult.new(nil, false, false, false, false, 0, :no_match_found) }
    let(:validation_result) { ParticipantValidationService.validate(trn:, nino:, full_name:, date_of_birth: dob) }

    context "when neither trn nor nino is provided" do
      let(:trn) { nil }
      let(:nino) { nil }

      it "returns nil" do
        expect(validation_result).to be_nil
      end
    end

    context "given that it calls DQTCheckRecord" do
      before do
        allow(DQTRecordCheck).to receive(:new).and_return(check_service)
        allow(check_service).to receive(:call).and_return(check_result)
      end

      context "when the participant cannot be found" do
        let(:check_result) { no_result }

        it "returns nil" do
          expect(validation_result).to eql nil
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

      context "when 3 of 4 things match" do
        context "when only first name matches" do
          let(:check_result) { no_result }
          let(:validation_result) do
            ParticipantValidationService.validate(
              trn:,
              nino: "WRONG",
              full_name: full_name.split(" ").first.to_s,
              date_of_birth: dob,
            )
          end

          it "returns nil" do
            expect(validation_result).to be_nil
          end
        end

        context "when config check_first_name_only: true" do
          let(:validation_result) do
            ParticipantValidationService.validate(
              trn:,
              nino: "WRONG",
              full_name: first_name,
              date_of_birth: dob,
              config: { check_first_name_only: true },
            )
          end

          it "returns validated details" do
            expect(validation_result).to eql(build_validation_result(trn:))
          end
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

      context "when the participant has previously participated" do
        let!(:eligibility) { create(:ineligible_participant, trn:, reason: :previous_induction_and_participation) }

        it "returns returns the correct previous_participation flags" do
          expect(validation_result).to eql(build_validation_result(trn:, options: { previous_participation: true }))
        end
      end

      context "with induction data" do
        let(:induction_status) { "Pass" }
        let(:induction_periods) do
          [{ "startDate" => induction_start_date, "endDate" => induction_completion_date }]
        end
        let(:induction) do
          {
            "startDate" => induction_start_date,
            "endDate" => induction_completion_date,
            "status" => induction_status,
            "periods" => induction_periods,
          }
        end

        context "when the participant has previously had an induction" do
          it "returns returns the correct previous_participation flags" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction with nil start_date" do
          let(:induction_start_date) { nil }
          let(:induction_completion_date) { nil }
          let(:induction_periods) { [] }

          it "does not raise an error" do
            expect { validation_result }.not_to raise_error
          end

          it "returns previous_induction as false" do
            expect(validation_result[:previous_induction]).to eq false
          end

          it "returns no_induction as true" do
            expect(validation_result[:no_induction]).to eq true
          end

          it "returns induction_start_date as nil" do
            expect(validation_result[:induction_start_date]).to be_nil
          end
        end

        context "when the participant's induction status is InProgress" do
          let(:induction_status) { "InProgress" }
          let(:induction_completion_date) { nil }

          it "does not raise an error" do
            expect { validation_result }.not_to raise_error
          end

          it "returns previous_induction as false" do
            expect(validation_result[:previous_induction]).to eq false
          end

          it "returns no_induction as false" do
            expect(validation_result[:no_induction]).to eq false
          end

          it "returns induction_start_date" do
            expect(validation_result[:induction_start_date]).to eq(induction_start_date)
          end
        end

        context "when the participant's induction status is Not Yet Completed" do
          let(:induction_status) { "Not Yet Completed" }
          let(:induction_completion_date) { nil }

          it "does not raise an error" do
            expect { validation_result }.not_to raise_error
          end

          it "returns previous_induction as false" do
            expect(validation_result[:previous_induction]).to eq false
          end

          it "returns no_induction as false" do
            expect(validation_result[:no_induction]).to eq false
          end

          it "returns induction_start_date" do
            expect(validation_result[:induction_start_date]).to eq(induction_start_date)
          end
        end

        context "when the participant has previously had an induction and participation" do
          let!(:eligibility) { create(:ineligible_participant, trn:, reason: :previous_participation) }

          it "returns returns both flags" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, previous_participation: true, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction start date in or after September this year" do
          let(:induction_start_date) { Time.zone.parse("2021-09-01T00:00:00Z") }
          let(:induction_completion_date) { nil }

          it "returns false for previous induction" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: false, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction start date is exactly on the threshold" do
          let(:induction_start_date) { Time.zone.parse("2021-08-31T23:00:00Z") }
          let(:induction_completion_date) { nil }

          it "returns false for previous induction and parses timezones correctly" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: false, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction start date before September 2021" do
          let(:induction_start_date) { Time.zone.parse("2021-08-31T22:59:59Z") }
          let(:induction_completion_date) { nil }

          it "returns true for previous induction" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction with the status of 'Exempt'" do
          let(:induction_status) { "Exempt" }
          let(:induction_start_date) { nil }
          let(:induction_completion_date) { nil }
          let(:induction_periods) { [] }

          it "sets exempt_from_induction to true" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { exempt_from_induction: true, no_induction: true }))
          end
        end

        context "when the participant's induction status is Not Yet Completed" do
          let(:induction) do
            {
              "periods" => [{ "startDate" => induction_start_date }],
              "status" => "Not Yet Completed",
            }
          end

          it "does not raise an error" do
            expect { validation_result }.not_to raise_error
          end

          it "returns previous_induction as false" do
            expect(validation_result[:previous_induction]).to eq false
          end

          it "returns no_induction as false" do
            expect(validation_result[:no_induction]).to eq false
          end

          it "returns induction_start_date" do
            expect(validation_result[:induction_start_date]).to eq(induction_start_date)
          end
        end

        context "when the participant has previously had an induction and participation" do
          let!(:eligibility) { create(:ineligible_participant, trn:, reason: :previous_participation) }
          let(:induction) do
            {
              "periods" => [{ "startDate" => induction_start_date }],
              "completion_date" => induction_completion_date,
              "status" => "Pass",
              "state" => 0,
              "state_name" => "Active",
            }
          end

          it "returns returns both flags" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, previous_participation: true, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction start date in or after September this year" do
          let(:induction_start_date) { Time.zone.parse("2021-09-01T00:00:00Z") }
          let(:induction_completion_date) { nil }
          let(:induction) do
            {
              "periods" => [{ "startDate" => induction_start_date }],
              "completion_date" => induction_completion_date,
              "status" => "Pass",
              "state" => 0,
              "state_name" => "Active",
            }
          end

          it "returns false for previous induction" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: false, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction start date is exactly on the threshold" do
          let(:induction_start_date) { Time.zone.parse("2021-08-31T23:00:00Z") }
          let(:induction_completion_date) { nil }
          let(:induction) do
            {
              "periods" => [{ "startDate" => induction_start_date }],
              "completion_date" => induction_completion_date,
              "status" => "Pass",
              "state" => 0,
              "state_name" => "Active",
            }
          end

          it "returns false for previous induction and parses timezones correctly" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: false, no_induction: false, induction_start_date: }))
          end
        end

        context "when the participant has an induction start date before September 2021" do
          let(:induction_start_date) { Time.zone.parse("2021-08-31T22:59:59Z") }
          let(:induction_completion_date) { nil }
          let(:induction) do
            {
              "periods" => [{ "startDate" => induction_start_date }],
              "completion_date" => induction_completion_date,
              "status" => "Pass",
              "state" => 0,
              "state_name" => "Active",
            }
          end

          it "returns true for previous induction" do
            expect(validation_result).to eql(build_validation_result(trn:, options: { previous_induction: true, no_induction: false, induction_start_date: }))
          end
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
      induction_start_date: nil,
    }.merge(options)
  end
end
