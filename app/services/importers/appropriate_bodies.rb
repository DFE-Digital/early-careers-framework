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
    end
  end
end
