# frozen_string_literal: true

require "rake"

namespace :support do
  namespace :induction_programmes do
    namespace :fip do
      desc "Looks for a FIP induction programme for a school, if it cannot find one matching the provided details it will create one"
      task :find_or_create, %i[school_urn cohort_year lead_provider_name delivery_partner_name] => :environment do |_task, args|
        school_urn = args.school_urn
        lead_provider_name = args.lead_provider_name
        delivery_partner_name = args.delivery_partner_name
        cohort_year = args.cohort_year

        Support::InductionProgrammes::Fip::FindOrCreate.call(
          school_urn:,
          lead_provider_name:,
          delivery_partner_name:,
          cohort_year:,
        )
      end

      desc "DRY RUN (rolls back on completion): Looks for a FIP induction programme for a school, if it cannot find one matching the provided details it will create one"
      task :find_or_create_dry_run, %i[school_urn cohort_year lead_provider_name delivery_partner_name] => :environment do |_task, args|
        school_urn = args.school_urn
        lead_provider_name = args.lead_provider_name
        delivery_partner_name = args.delivery_partner_name
        cohort_year = args.cohort_year

        Support::InductionProgrammes::Fip::FindOrCreate.new(
          school_urn:,
          lead_provider_name:,
          delivery_partner_name:,
          cohort_year:,
        ).dry_run
      end
    end

    namespace :cip do
      desc "Looks for a CIP induction programme for a school, if it cannot find one matching the provided details it will create one"
      task :find_or_create, %i[school_urn cohort_year cip_name] => :environment do |_task, args|
        school_urn = args.school_urn
        cohort_year = args.cohort_year
        cip_name = args.cip_name

        Support::InductionProgrammes::Cip::FindOrCreate.call(school_urn:, cohort_year:, cip_name:)
      end

      desc "DRY RUN (rolls back on completion): Looks for a FIP induction programme for a school, if it cannot find one matching the provided details it will create one"
      task :find_or_create_dry_run, %i[school_urn cohort_year cip_name] => :environment do |_task, args|
        school_urn = args.school_urn
        cohort_year = args.cohort_year
        cip_name = args.cip_name

        Support::InductionProgrammes::Cip::FindOrCreate.new(school_urn:, cohort_year:, cip_name:).dry_run
      end
    end
  end
end
