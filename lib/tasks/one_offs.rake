# frozen_string_literal: true

namespace :one_offs do
  desc "backfill teacher catchement iso country code"
  task backfill_teacher_catchment_iso_country_code: :environment do
    NPQApplication.where.not(teacher_catchment_country: nil).find_each do |npq_application|
      country = ISO3166::Country.find_country_by_iso_short_name(npq_application.teacher_catchment_country)
      npq_application.update!(teacher_catchment_iso_country_code: country.alpha3)
    end
  end
end
