# frozen_string_literal: true

module Importers
  class AppropriateBodies
    def self.call
      CSV.foreach(Rails.root.join("data/appropriate_bodies.csv"), "r", headers: true) do |row|
        name = row["name"]
        body_type = row["type"]

        Rails.logger.debug("seeding appropriate body #{name} of type #{body_type}")

        AppropriateBody.find_or_create_by!(name:, body_type:)
      end

      # remove NTA from 2023 onwards
      AppropriateBody.find_by(body_type: "national", name: "National Teacher Accreditation (NTA)")&.update!(disable_from_year: 2023)
    end
  end
end
