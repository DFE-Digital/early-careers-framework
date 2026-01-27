# frozen_string_literal: true

require "json"

class ContractsController < ApplicationController
  layout false

  content_security_policy false, only: [:show]

  def show
    tree = {
      name: "Contracts",
  children: [],
    }

    LeadProvider.find_each do |lead_provider|
      lead_node = {
        name: lead_provider.name,
        children: [],
      }

      Cohort.order(start_year: :asc).each do |cohort|
        cpd_lead_provider = lead_provider.cpd_lead_provider

        call_off_contracts = CallOffContract
          .includes(:participant_bands)
          .not_flagged_as_unused
          .joins(:cohort, :lead_provider)
          .where(cohort:, lead_provider:)
          .to_a
          .sort_by { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value }

        next if call_off_contracts.empty?

        cohort_node = {
          name: cohort.start_year.to_s,
          children: [],
        }

        # ---- Call-off contracts ----
        call_off_node = {
          name: "CallOffContract",
          children: [],
        }

        previous_statement = nil
        call_off_contracts.each do |call_off_contract|
          version_node = {
            name: "Version: #{call_off_contract.version}",
            details: call_off_contract.describe,
            children: [],
          }

          Finance::Statement
            .includes(:cohort, :cpd_lead_provider)
            .where(
              cohort:,
              cpd_lead_provider:,
              contract_version: call_off_contract.version,
            )
            .to_a
            .sort_by { |s| Date.strptime(s[:name], "%B %Y") }
            .each.with_index do |statement, index|
              version_node[:children] << if index.zero? && previous_statement && (Date.strptime(statement.name, "%B %Y") <= Date.strptime(previous_statement.name, "%B %Y"))
                                           { name: "#{statement.name} OUT OF ORDER!" }
                                         else
                                           { name: statement.name }
                                         end
              previous_statement = statement
            end

          call_off_node[:children] << version_node
        end

        cohort_node[:children] << call_off_node

        # ---- Mentor call-off contracts (conditional) ----
        if cohort.mentor_funding?
          mentor_call_off_contracts = MentorCallOffContract
            .joins(:cohort, :lead_provider)
            .where(cohort:, lead_provider:)
            .to_a
            .sort_by { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value }

          mentor_node = {
            name: "MentorCallOffContract",
            children: [],
          }

          previous_statement = nil
          mentor_call_off_contracts.each do |mentor_call_off_contract|
            version_node = {
              name: "Version: #{mentor_call_off_contract.version}",
              details: mentor_call_off_contract.describe,
              children: [],
            }

            Finance::Statement
              .includes(:cohort, :cpd_lead_provider)
              .where(
                cohort:,
                cpd_lead_provider:,
                contract_version: mentor_call_off_contract.version,
              )
              .to_a
              .sort_by { |s| Date.strptime(s[:name], "%B %Y") }
              .each.with_index do |statement, index|
                version_node[:children] << if index.zero? && previous_statement && (Date.strptime(statement.name, "%B %Y") <= Date.strptime(previous_statement.name, "%B %Y"))
                                             { name: "#{statement.name} OUT OF ORDER!" }
                                           else
                                             { name: statement.name }
                                           end
                previous_statement = statement
              end

            mentor_node[:children] << version_node
          end

          cohort_node[:children] << mentor_node
        end

        lead_node[:children] << cohort_node
      end

      tree[:children] << lead_node
    end

    @json = tree.to_json
  end
end
