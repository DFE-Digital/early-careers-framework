# frozen_string_literal: true

desc "Appropriate bodies scrape and load"
namespace :appropriate_bodies do
  desc "Update appropriate bodies"
  task update_csv: :environment do
    source_url = "https://www.gov.uk/government/publications/statutory-teacher-induction-appropriate-bodies/find-an-appropriate-body"
    allowed_types = %w[local_authority teaching_school_hub]

    csv_path = Rails.root.join("data/appropriate_bodies.csv")

    puts "Updating data/appropriate_bodies.csv from #{source_url}"
    CSV.open(csv_path, "wb") do |csv|
      csv << %w[name type]

      doc = Nokogiri::HTML5(URI.parse(source_url).open)
      doc.css("table th[scope='row']").each do |row|
        type = row.parent.css("td").first.text.downcase.gsub(" ", "_")
        if allowed_types.include? type
          name = row.text
          csv << [name, type]
        end
      end
    end
  end

  desc "Import appropriate bodies CSV"
  task import: :environment do
    CSV.foreach(Rails.root.join("data/appropriate_bodies.csv"), "r", headers: true) do |row|
      AppropriateBody.find_or_create_by!(name: row["name"], body_type: row["type"])
    end
  end
end
