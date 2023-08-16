# frozen_string_literal: true

require "rake"
require "participant_profile_deduplicator"

namespace :participant_profile_deduplicator do
  desc "Perform a dry-run of the deduplication task"
  task :dedup_dry_run, %i[primary_profile_id duplicate_profile_id] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)
    deduplicator = ParticipantProfileDeduplicator.new(args[:primary_profile_id], args[:duplicate_profile_id], dry_run: true)
    deduplicator.dedup!
  end

  desc "Perform a dry-run across all duplicates for a lead provider"
  task :dedup_dry_run_by_lead_provider, %i[] => :environment do |_task, args|
    Rails.logger = Logger.new(nil)
    primary_duplicate_profiles = Finance::ECF::Duplicate
      .primary_profiles
      .includes(:latest_induction_record)
      .to_a
      
    primary_duplicate_profiles = primary_duplicate_profiles.sort_by { |d| d.latest_induction_record.lead_provider_id&.gsub("-", "")&.hex || 0 }
      
    lead_providers = LeadProvider.all.index_by(&:id)
    
    file = "#{Rails.root}/duplicates.csv"
    headers = ["Primary Profile ID", "Duplicate Profile ID(s)", "Status", "Details"]
    last_lead_provider_id = -1

    CSV.open(file, 'w', write_headers: false) do |writer|
      primary_duplicate_profiles.each_with_index do |duplicate, index|
        puts "#{index + 1}/#{primary_duplicate_profiles.count}"

        lead_provider_id = duplicate.latest_induction_record.lead_provider_id
        lead_provider = lead_providers[lead_provider_id]
        lead_provider_name = lead_provider&.name || "unknown (#{lead_provider_id})"
        duplicate_profiles = duplicate.duplicate_participant_profiles

        if last_lead_provider_id != lead_provider_id
          last_lead_provider_id = lead_provider_id
          writer << []
          writer << [lead_provider_name]
          writer << headers
        end

        if duplicate_profiles.count > 1
          writer << [duplicate.primary_participant_profile_id, duplicate_profiles.map(&:id), "Skipped", "Multiple duplicates are not supported"] 
          next
        end

        duplicate_profile_id = duplicate_profiles.first.id
        deduplicator = ParticipantProfileDeduplicator.new(duplicate.primary_participant_profile_id, duplicate_profile_id, dry_run: true)
        deduplicator.dedup!

        writer << [duplicate.primary_participant_profile_id, duplicate_profile_id, "Processable", ""] 
      rescue => e
        writer << [duplicate.primary_participant_profile_id, duplicate_profile_id, "Failed", e.message] 
      end
    end
  end
end
