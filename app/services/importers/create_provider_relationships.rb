# frozen_string_literal: true

require "csv"

module Importers
  class CreateProviderRelationships
    def initialize(path_to_csv:, cohort_start_year:, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @cohort_start_year = cohort_start_year.to_i
      @logger = logger
    end

    def call
      check_headers!

      logger.info "CreateProviderRelationships: Started!"

      ActiveRecord::Base.transaction do
        rows.each do |row|
          create_provider_relationships(row)
        end
      end

      logger.info "CreateProviderRelationships: Finished!"
    end

  private

    attr_reader :path_to_csv, :cohort_start_year, :logger

    def check_headers!
      unless %w[delivery_partner_id lead_provider_name].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end

    def cohort
      @cohort ||= Cohort.find_by_start_year!(cohort_start_year)
    end

    def delivery_partner(id)
      DeliveryPartner.find(id)
    end

    def lead_provider(name)
      LeadProvider.joins(:cohorts).find_by!(name:, cohorts: cohort)
    end

    def create_provider_relationships(row)
      lead_provider = lead_provider(row["lead_provider_name"])
      delivery_partner = delivery_partner(row["delivery_partner_id"])

      logger.info "CreateProviderRelationships: Creating #{lead_provider.name} / #{delivery_partner.name} relationship in #{cohort_start_year}"

      ProviderRelationship.find_or_create_by!(cohort:, lead_provider:, delivery_partner:)

      logger.info "CreateProviderRelationships: #{lead_provider.name} / #{delivery_partner.name} relationship in #{cohort_start_year} successfully created"
    end
  end
end
