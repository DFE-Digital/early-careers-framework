# frozen_string_literal: true

require "rails_helper"

module Dqt
  class Api
    class V1
      describe DQTRecord do
        subject(:dqt_record) { described_class.new(client: Client.new(host: "dqt.com")) }

        describe "#show" do
          subject(:show) { dqt_record.show(params: params_args) }

          let(:trn) { "1234567" }
          let(:nino) { "AA123456C" }

          let(:params_args) do
            {
              teacher_reference_number: trn,
              national_insurance_number: nino,
            }
          end

          let(:expected_dqt_record) { build_dqt_record(trn: trn, nino: nino) }

          let!(:show_endpoint) do
            stub_dqt_api(expected_dqt_record: expected_dqt_record)
          end

          it "makes correct request" do
            show

            expect(show_endpoint).to have_been_requested
          end

          it "returns qualified teaching status" do
            expect(show).to eq(expected_dqt_record)
          end

          context "when qtsAwardDate is nil" do
            let(:expected_dqt_record) do
              r = build_dqt_record(trn: trn, nino: nino)
              r[:qts_date] = nil
              r
            end

            it "does not raise an error" do
              expect { show }.not_to raise_error
            end
          end
        end

      private

        def build_dqt_record(trn:, nino:)
          {
            teacher_reference_number: trn,
            full_name: Faker::Name.name,
            date_of_birth: Faker::Date.birthday,
            national_insurance_number: nino,
            qts_date: Faker::Date.backward(days: 730),
            active_alert: Faker::Boolean.boolean,
          }
        end

        def stub_dqt_api(expected_dqt_record:)
          stub_request(:get, %r{/api/qualified-teachers/qualified-teaching-status}).with(
            query: WebMock::API.hash_including(
              {
                trn: expected_dqt_record[:teacher_reference_number],
                ni: expected_dqt_record[:national_insurance_number],
              },
            ),
          ).to_return(
            body: dqt_body(expected_dqt_record: expected_dqt_record),
          )
        end

        def dqt_body(expected_dqt_record:)
          hash = {
            data: [
              {
                "id": 5,
                "trn": expected_dqt_record[:teacher_reference_number],
                "name": expected_dqt_record[:full_name],
                "doB": expected_dqt_record[:date_of_birth],
                "niNumber": expected_dqt_record[:national_insurance_number],
                "ittSubject1Code": "G100",
                "ittSubject2Code": "NULL",
                "ittSubject3Code": "NULL",
                "activeAlert": expected_dqt_record[:active_alert],
                "qualificationName": "Professional Graduate Certificate in Education",
                "ittStartDate": "2014-08-31T23:00:00",
                "teacherStatus": "Assessment Only Route",
              },
            ],
            "message": nil,
          }

          hash[:data][0][:qtsAwardDate] = expected_dqt_record[:qts_date].strftime("%Y-%m-%d %H:%M:%S") if expected_dqt_record[:qts_date].present?

          hash.to_json
        end
      end
    end
  end
end
