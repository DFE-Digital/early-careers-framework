# frozen_string_literal: true

module Importers
  class CreateCallOffContract
    def call
      LeadProvider.all.each do |lp|
        [cohort_2021, cohort_2022, cohort_2023].each do |cohort|
          sample_call_off_contract = CallOffContract.find_or_create_by!(
            lead_provider: lp,
            version: example_contract_data[:version] || "0.0.1",
            uplift_target: example_contract_data[:uplift_target],
            uplift_amount: example_contract_data[:uplift_amount],
            recruitment_target: example_contract_data[:recruitment_target],
            revised_target: example_contract_data[:revised_target],
            set_up_fee: example_contract_data[:set_up_fee],
            raw: example_contract_data.to_json,
            cohort:,
          )

          %i[band_a band_b band_c band_d].each do |band|
            src = example_contract_data[band]
            ParticipantBand.find_or_create_by!(
              call_off_contract: sample_call_off_contract,
              min: src[:min],
              max: src[:max],
              per_participant: src[:per_participant],
            )
          end
        end
      end
    end

  private

    def cohort_2021
      @cohort_2021 ||= Cohort.find_or_create_by!(start_year: 2021)
    end

    def cohort_2022
      @cohort_2022 ||= Cohort.find_or_create_by!(start_year: 2022)
    end

    def cohort_2023
      @cohort_2023 ||= Cohort.find_or_create_by!(start_year: 2023)
    end

    def example_contract_data
      @example_contract_data ||= {
        uplift_target: 0.33,
        uplift_amount: 100,
        recruitment_target: 4500,
        revised_target: (4500 * 1.02).to_i,
        set_up_fee: 0,
        band_a: {
          max: 10,
          per_participant: 995,
        },
        band_b: {
          min: 11,
          max: 20,
          per_participant: 979,
        },
        band_c: {
          min: 21,
          max: 30,
          per_participant: 966,
        },
        band_d: {
          min: 31,
          max: 40,
          per_participant: 966,
        },
      }
    end
  end
end
