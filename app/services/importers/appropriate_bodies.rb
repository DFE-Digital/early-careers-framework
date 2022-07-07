# frozen_string_literal: true

module Importers
  class AppropriateBodies
    def self.call
      CSV.foreach(Rails.root.join("data/appropriate_bodies.csv"), "r", headers: true) do |row|
        AppropriateBody.find_or_create_by!(name: row["name"], body_type: row["type"])
      end
    end
  end
end
