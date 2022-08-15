# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NPQApplications::EligibilityImportJob do
  describe "#perform" do
    subject { described_class.new.perform(npq_application_eligibility_import) }

    let(:npq_application_eligibility_import) do
      NPQApplications::EligibilityImport.create!(filename:, user: create(:user, :admin))
    end

    let(:npq_application_to_mark_funded) { create(:npq_application) }
    let(:npq_application_to_mark_unfunded) { create(:npq_application, :funded) }
    let(:npq_application_to_mark_other) { create(:npq_application) }
    let(:npq_application_to_mark_invalid_status_code) { create(:npq_application) }

    let(:fake_ecf_id) { SecureRandom.uuid }

    let(:csv_headers) { %w[ecf_id eligible_for_funding funding_eligiblity_status_code] }

    let(:csv_file_contents) do
      CSV.generate do |csv|
        csv << csv_headers
        # The array sample is to check that different cases of true all resolve to the boolean value true
        # We also in various other values add padding to check that whitespace is being stripped out
        csv << [npq_application_to_mark_funded.id, ["TRUE", "true", "TRue", " TRUE"].sample, "funded"]
        csv << [npq_application_to_mark_unfunded.id, "FALSE", "ineligible_establishment_type  "]
        csv << ["#{npq_application_to_mark_other.id} ", " no", "previously_funded"]
        csv << [npq_application_to_mark_invalid_status_code.id, "false", "not funded"]
        csv << [fake_ecf_id, "TRUE", "funded"]
      end
    end

    let(:filename) { "file.csv" }
    let(:parent_folder_id) { SecureRandom.uuid }
    let(:drive_id) { SecureRandom.uuid }
    let(:file_id) { SecureRandom.uuid }

    let(:access_token) { "1/abcdef1234567890" }

    let(:stubbed_files) do
      [
        {
          "kind" => "drive#file",
          "id" => file_id,
          "name" => filename,
          "mimeType" => "text/csv",
          "teamDriveId" => drive_id,
          "driveId" => drive_id,
        },
      ]
    end

    before do
      ENV.stub(:[]).and_call_original
      ENV.stub(:[]).with("GOOGLE_CLIENT_ID").and_return("foo")
      ENV.stub(:[]).with("GOOGLE_CLIENT_EMAIL").and_return("foo")
      ENV.stub(:[]).with("GOOGLE_ACCOUNT_TYPE").and_return("foo")
      ENV.stub(:[]).with("GOOGLE_PRIVATE_KEY").and_return(OpenSSL::PKey::RSA.generate(2048).to_s)
      ENV.stub(:[]).with("GOOGLE_DRIVE_NPQ_DOWNLOAD_FOLDER_ID").and_return(parent_folder_id)

      stub_authentication
      stub_list_files(stubbed_files:)
      stub_download_file
    end

    it "downloads file and updates records", :aggregate_failures do
      expect {
        travel_to Time.zone.parse("2022-7-1 11:31") do
          subject
        end
      }.to change {
        [
          slice_data(npq_application_to_mark_funded.reload),
          slice_data(npq_application_to_mark_unfunded.reload),
          slice_data(npq_application_to_mark_other.reload),
          slice_data(npq_application_to_mark_invalid_status_code.reload),
        ]
      }.from(
        [
          { "eligible_for_funding" => false, "funding_eligiblity_status_code" => "ineligible_establishment_type" },
          { "eligible_for_funding" => true,  "funding_eligiblity_status_code" => "funded" },
          { "eligible_for_funding" => false, "funding_eligiblity_status_code" => "ineligible_establishment_type" },
          { "eligible_for_funding" => false, "funding_eligiblity_status_code" => "ineligible_establishment_type" },
        ],
      ).to(
        [
          { "eligible_for_funding" => true,  "funding_eligiblity_status_code" => "funded" },
          { "eligible_for_funding" => false, "funding_eligiblity_status_code" => "ineligible_establishment_type" },
          { "eligible_for_funding" => false, "funding_eligiblity_status_code" => "previously_funded" },
          { "eligible_for_funding" => false, "funding_eligiblity_status_code" => "ineligible_establishment_type" }, # invalid status codes don't persist
        ],
      )

      expect(npq_application_eligibility_import.updated_records).to eq(3)
      expect(npq_application_eligibility_import.import_errors).to match([
        "ROW 5: Application with ecf_id #{npq_application_to_mark_invalid_status_code.id} invalid: Invalid funding eligibility status code, `not funded`",
        "ROW 6: Application with ecf_id #{fake_ecf_id} not found",
      ])
      expect(npq_application_eligibility_import.status).to eq("completed_with_errors")
    end

    context "when there are multiple files with the same name" do
      let(:stubbed_files) do
        [
          {
            "kind" => "drive#file",
            "id" => file_id,
            "name" => filename,
            "mimeType" => "text/csv",
            "teamDriveId" => drive_id,
            "driveId" => drive_id,
          },
          {
            "kind" => "drive#file",
            "id" => SecureRandom.uuid,
            "name" => filename,
            "mimeType" => "text/csv",
            "teamDriveId" => drive_id,
            "driveId" => drive_id,
          },
        ]
      end

      it "cancels the import", :aggregate_failures do
        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }

        expect(npq_application_eligibility_import.updated_records).to eq(nil)
        expect(npq_application_eligibility_import.import_errors).to match(["More than one file was found with name file.csv. To avoid ambiguity the import was cancelled."])
        expect(npq_application_eligibility_import.status).to eq("failed")
      end
    end

    context "when there are no files matching the provided name" do
      let(:stubbed_files) { [] }

      it "cancels the import", :aggregate_failures do
        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }

        expect(npq_application_eligibility_import.updated_records).to eq(nil)
        expect(npq_application_eligibility_import.import_errors).to match(["File not found"])
        expect(npq_application_eligibility_import.status).to eq("failed")
      end
    end

    context "when there is an exception during download" do
      before do
        allow_any_instance_of(StringIO).to receive(:rewind).and_raise(io_error)
      end

      let(:io_error) { IOError.new("Error downloading file") }

      it "cancels the import, sends an error to sentry, and directs the user to an admin", :aggregate_failures do
        expect(Sentry).to receive(:capture_exception).with(
          io_error,
          hint: {
            filename:,
            folder: parent_folder_id,
          },
        )

        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }

        expect(npq_application_eligibility_import.updated_records).to eq(nil)
        expect(npq_application_eligibility_import.import_errors).to match(["Error downloading file, contact an administrator for details"])
        expect(npq_application_eligibility_import.status).to eq("failed")
      end
    end

    context "when there is an exception during updating" do
      before do
        allow_any_instance_of(NPQApplication).to receive(:update).and_raise(update_error)
      end

      let(:update_error) { ActiveRecord::ActiveRecordError.new("Error updating record!") }

      it "cancels the import, sends an error to sentry, and directs the user to an admin", :aggregate_failures do
        [
          npq_application_to_mark_funded,
          npq_application_to_mark_unfunded,
          npq_application_to_mark_other,
        ].each do |application|
          expect(Sentry).to receive(:capture_exception).with(
            update_error,
            hint: {
              application_id: application.id,
              eligibility_import_id: npq_application_eligibility_import.id,
            },
          )
        end

        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }

        expect(npq_application_eligibility_import.updated_records).to eq(0)
        expect(npq_application_eligibility_import.import_errors).to match([
          "ROW 2: Could not update Application with ecf_id #{npq_application_to_mark_funded.id}, contact an administrator for details",
          "ROW 3: Could not update Application with ecf_id #{npq_application_to_mark_unfunded.id}, contact an administrator for details",
          "ROW 4: Could not update Application with ecf_id #{npq_application_to_mark_other.id}, contact an administrator for details",
          "ROW 5: Application with ecf_id #{npq_application_to_mark_invalid_status_code.id} invalid: Invalid funding eligibility status code, `not funded`",
          "ROW 6: Application with ecf_id #{fake_ecf_id} not found",
        ])
        expect(npq_application_eligibility_import.status).to eq("completed_with_errors")
      end
    end

    context "when there is an exception at an unexpected step of processing" do
      before do
        allow_any_instance_of(NPQApplications::EligibilityImport).to receive(:begin_processing!).and_raise(update_error)
      end

      let(:update_error) { ActiveRecord::ActiveRecordError.new("Error updating record!") }

      it "cancels the import, sends an error to sentry, and directs the user to an admin", :aggregate_failures do
        expect(Sentry).to receive(:capture_exception).with(
          update_error,
          hint: {
            eligibility_import_id: npq_application_eligibility_import.id,
          },
        )

        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }

        expect(npq_application_eligibility_import.updated_records).to eq(nil)
        expect(npq_application_eligibility_import.import_errors).to match([
          "Processing Failed, contact an administrator for details",
        ])
        expect(npq_application_eligibility_import.status).to eq("failed")
      end
    end

    context "when there is an failure during updating" do
      before do
        # This forces a validation failure on model, so we have failed model saves
        allow_any_instance_of(NPQApplication).to receive(:eligible_for_funding_before_type_cast).and_return(nil)
      end

      it "cancels the import, sends an error to sentry, and directs the user to an admin", :aggregate_failures do
        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }
        expect(npq_application_eligibility_import.updated_records).to eq(0)
        expect(npq_application_eligibility_import.import_errors).to match([
          "ROW 2: Application with ecf_id #{npq_application_to_mark_funded.id} invalid: Eligible for funding before type cast is not included in the list",
          "ROW 3: Application with ecf_id #{npq_application_to_mark_unfunded.id} invalid: Eligible for funding before type cast is not included in the list",
          "ROW 4: Application with ecf_id #{npq_application_to_mark_other.id} invalid: Eligible for funding before type cast is not included in the list",
          "ROW 5: Application with ecf_id #{npq_application_to_mark_invalid_status_code.id} invalid: Invalid funding eligibility status code, `not funded`",
          "ROW 6: Application with ecf_id #{fake_ecf_id} not found",
        ])
        expect(npq_application_eligibility_import.status).to eq("completed_with_errors")
      end
    end

    context "when the file has too many columns" do
      let(:csv_headers) { %w[ecf_id eligible_for_funding funding_eligiblity_status_code foo] }

      it "downloads file and updates records", :aggregate_failures do
        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }

        expect(npq_application_eligibility_import.updated_records).to eq(nil)
        expect(npq_application_eligibility_import.import_errors).to match(["Invalid CSV headers, required headers are: ecf_id, eligible_for_funding, funding_eligiblity_status_code"])
        expect(npq_application_eligibility_import.status).to eq("failed")
      end
    end

    context "when the file has too few columns" do
      let(:csv_file_contents) do
        CSV.generate do |csv|
          csv << [:id]
          csv << [npq_application_to_mark_funded.id]
        end
      end

      it "downloads file and updates records", :aggregate_failures do
        expect {
          travel_to Time.zone.parse("2022-7-1 11:31") do
            subject
          end
        }.to_not change {
          [
            slice_data(npq_application_to_mark_funded.reload),
            slice_data(npq_application_to_mark_unfunded.reload),
            slice_data(npq_application_to_mark_other.reload),
            slice_data(npq_application_to_mark_invalid_status_code.reload),
          ]
        }

        expect(npq_application_eligibility_import.updated_records).to eq(nil)
        expect(npq_application_eligibility_import.import_errors).to match(["Invalid CSV headers, required headers are: ecf_id, eligible_for_funding, funding_eligiblity_status_code"])
        expect(npq_application_eligibility_import.status).to eq("failed")
      end
    end

    def slice_data(npq_application)
      npq_application.slice(:eligible_for_funding, :funding_eligiblity_status_code)
    end

    def stub_authentication
      body_fields = { "token_type" => "Bearer", "expires_in" => 3600, access_token: }
      body = MultiJson.dump body_fields
      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
        .to_return(body:,
                   status: 200,
                   headers: { "Content-Type" => "application/json" })
    end

    def stub_list_files(stubbed_files:)
      stub_request(:get, "https://www.googleapis.com/drive/v3/files?corpora=allDrives&includeItemsFromAllDrives=true&q=name%20=%20'#{filename}'%20and%20'#{parent_folder_id}'%20in%20parents&supportsAllDrives=true")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip,deflate",
            "Authorization" => "Bearer #{access_token}",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Date" => "Fri, 01 Jul 2022 11:31:00 GMT",
            "User-Agent" => /.+/,
            "X-Goog-Api-Client" => /.+/,
          },
        )
        .to_return(
          status: 200,
          body: {
            "kind" => "drive#fileList",
            "incompleteSearch" => false,
            "files" => stubbed_files,
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
          },
        )
    end

    def stub_download_file
      stub_request(:get, "https://www.googleapis.com/drive/v3/files/#{file_id}?alt=media&supportsAllDrives=true")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip,deflate",
            "Authorization" => "Bearer #{access_token}",
            "Date" => "Fri, 01 Jul 2022 11:31:00 GMT",
            "User-Agent" => /.+/,
            "X-Goog-Api-Client" => /.+/,
          },
        )
        .to_return(status: 200, body: csv_file_contents, headers: {})
    end
  end
end
