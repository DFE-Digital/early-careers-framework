# frozen_string_literal: true

desc "Appropriate bodies scrape and load"
namespace :appropriate_bodies do
  desc "Update appropriate bodies"
  task :update_csv do
    SOURCE_URL = "https://www.gov.uk/government/publications/statutory-teacher-induction-appropriate-bodies/find-an-appropriate-body"
    ALLOWED_TYPES = ["local_authority", "teaching_school_hub"]

    csv_path = Rails.root.join("data", "appropriate_bodies.csv")

    puts "Updating data/appropriate_bodies.csv from #{SOURCE_URL}"
    csv = CSV.open(csv_path, "wb") do |csv|
      csv << ["name", "type"]

      doc = Nokogiri::HTML5(URI.open(SOURCE_URL))
      doc.css("table th[scope='row']").each do |row|
        type = row.parent.css("td").first.text.downcase.gsub(" ", "_")
        if ALLOWED_TYPES.include? type
          name = row.text
          csv << [name, type]
        end
      end
    end
  end

  desc "Import appropriate bodies CSV"
  task import: :environment do
    CSV.foreach(Rails.root.join("data", "appropriate_bodies.csv"), "r", headers: true) do |row|
      ap = AppropriateBody.create(name: row["name"], body_type: row["type"])
    end
  end
end
