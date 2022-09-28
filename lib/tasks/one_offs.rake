# frozen_string_literal: true

namespace :one_offs do
  desc "backfill teacher catchement iso country code"
  task backfill_teacher_catchment_iso_country_code: :environment do
    uk_country = ISO3166::Country.find_country_by_any_name("United Kingdom")

    NPQApplication.where.not(teacher_catchment: [nil, "another"]).find_each do |npq_application|
      npq_application.update!(
        teacher_catchment_iso_country_code: uk_country.alpha3,
        teacher_catchment_country: uk_country.iso_short_name,
      )
    end

    NPQApplication.where.not(teacher_catchment_country: nil).find_each do |npq_application|
      if (country = ISO3166::Country.find_country_by_any_name(npq_application.teacher_catchment_country))
        npq_application.update!(teacher_catchment_iso_country_code: country.alpha3)
      else
        Sentry.capture_message("Could not find the ISO3166 alpha3 code for #{npq_application.teacher_catchment_country}.")
      end
    end
  end
end
