# frozen_string_literal: true

RSpec.describe Oneoffs::NPQ::CreateNewContractAndUpdateExistingStatements do
  let(:csv) { Tempfile.new("data.csv") }
  let(:cohort) { create(:cohort, start_year: 2024) }
  let(:payment_date_range) { Date.new(2024, 1, 1)..Date.new(2024, 1, 31) }

  let(:lead_provider_data) do
    {
      "Ambition Institute" => {
        course_data: {
          "npq-early-headship-coaching-offer" => {
            contract_version: "0.0.2",
            recruitment_target: 1,
            per_participant: 10,
          },
          "npq-headship" => {
            contract_version: "0.0.3",
            recruitment_target: 2,
            per_participant: 20,
          },
        },
        new_contract_version: "0.0.4",
      },
      "Best Practice Network" => {
        course_data: {
          "npq-early-headship-coaching-offer" => {
            contract_version: "0.0.4",
            recruitment_target: 1,
            per_participant: 10,
          },
          "npq-headship" => {
            contract_version: "0.0.5",
            recruitment_target: 2,
            per_participant: 20,
          },
        },
        new_contract_version: "0.0.6",
      },
    }
  end

  before do
    lead_provider_data.each do |lead_provider_name, course_identifier_data|
      cpd_lead_provider = create(:cpd_lead_provider, :with_npq_lead_provider, name: lead_provider_name)

      course_identifier_data[:course_data].each do |course_identifier, data|
        create(:npq_course, identifier: course_identifier)
        create(:npq_contract, npq_lead_provider: cpd_lead_provider.npq_lead_provider, course_identifier:, cohort:, version: data[:contract_version])
        create(:npq_statement, cohort:, cpd_lead_provider:, contract_version: data[:contract_version], payment_date: Date.new(2024, 1, 2))
      end
    end
  end

  subject { described_class.new(path_to_csv: csv.path, cohort_year: cohort.start_year, payment_date_range:) }

  describe "#call" do
    before do
      csv.write "provider_name,cohort_year,course_identifier,recruitment_target,per_participant,service_fee_installments,special_course,monthly_service_fee,funding_cap"
      csv.write "\n"
      csv.write "Ambition Institute,2024,npq-early-headship-coaching-offer,33,800,0,FALSE,0,1"
      csv.write "\n"
      csv.write "Ambition Institute,2024,npq-headship,33,800,0,FALSE,0,1"
      csv.write "\n"
      csv.write "Best Practice Network,2024,npq-early-headship-coaching-offer,33,800,0,FALSE,0,1"
      csv.write "\n"
      csv.write "Best Practice Network,2024,npq-headship,33,800,0,FALSE,0,1"
      csv.write "\n"
      csv.close
    end

    it "creates contracts with correct values" do
      expect { subject.call }.to change { NPQContract.count }.by(4)

      lead_provider_data.each do |lead_provider_name, course_identifier_data|
        cpd_lead_provider = CpdLeadProvider.find_by(name: lead_provider_name)

        course_identifier_data[:course_data].each_key do |course_identifier|
          contract = NPQContract.where(
            course_identifier:,
            npq_lead_provider: cpd_lead_provider.npq_lead_provider,
          ).order(:created_at).last

          expect(contract.npq_lead_provider.name).to eql(cpd_lead_provider.npq_lead_provider.name)
          expect(contract.recruitment_target).to eql(33)
          expect(contract.course_identifier).to eql(course_identifier)
          expect(contract.per_participant).to eql(800)
          expect(contract.cohort).to eql(cohort)
          expect(contract.version).to eql(lead_provider_data[lead_provider_name][:new_contract_version])
        end
      end
    end

    it "updates the statements with the new contract version" do
      subject.call

      lead_provider_data.each_key do |lead_provider_name|
        cpd_lead_provider = CpdLeadProvider.find_by(name: lead_provider_name)
        expect(Finance::Statement::NPQ.where(cpd_lead_provider:).pluck(:contract_version).uniq).to eql([lead_provider_data[lead_provider_name][:new_contract_version]])
      end
    end
  end
end
