# frozen_string_literal: true

module Api
  module V3
    module ECF
      class BuildTransfers
        def initialize(cpd_lead_provider:, participant_profile:)
          @cpd_lead_provider = cpd_lead_provider
          @induction_records = participant_profile.induction_records
        end

        def call
          return [] unless cpd_lead_provider

          @transfers = []
          @traversed_induction_records = []
          @leaving_induction_record = nil
          @joining_induction_record = nil

          build_transfers
        end

      private

        attr_reader :cpd_lead_provider, :induction_records

        def build_transfers
          sorted_induction_records.each do |induction_record|
            next unless induction_record.induction_status == "leaving"

            ## set leaving induction record and mark as traversed
            @leaving_induction_record = induction_record
            @traversed_induction_records << @leaving_induction_record

            ## select possible joining induction record from remaining induction records
            select_joining_induction_record

            ## add complete transfer if joining induction record found
            add_complete_transfer

            ## add incomplete transfer if no corresponding joining induction record found
            add_incomplete_transfer

            ## reset induction records for next batch
            @leaving_induction_record = nil
            @joining_induction_record = nil
          end

          @transfers
        end

        def select_joining_induction_record
          (sorted_induction_records - @traversed_induction_records).each do |possible_joining_induction_record|
            next unless possible_joining_induction_record.induction_status != "leaving" && different_school?(possible_joining_induction_record:) && possible_joining_induction_record.school_transfer

            @joining_induction_record = possible_joining_induction_record
            @traversed_induction_records << @joining_induction_record

            break
          end
        end

        def add_complete_transfer
          if @leaving_induction_record.present? &&
              @joining_induction_record.present? && (@leaving_induction_record.induction_programme.partnership&.lead_provider == cpd_lead_provider.lead_provider || @joining_induction_record.induction_programme.partnership&.lead_provider == cpd_lead_provider.lead_provider)
            @transfers << [@leaving_induction_record, @joining_induction_record]
          end
        end

        def add_incomplete_transfer
          if @leaving_induction_record.present? && @joining_induction_record.blank? && @leaving_induction_record.induction_programme.partnership&.lead_provider == cpd_lead_provider.lead_provider
            @transfers << [@leaving_induction_record, nil]
          end
        end

        def sorted_induction_records
          induction_records.sort_by(&:created_at)
        end

        def different_school?(possible_joining_induction_record:)
          possible_joining_induction_record.induction_programme.school_cohort.school_id != @leaving_induction_record.induction_programme.school_cohort.school_id
        end
      end
    end
  end
end
