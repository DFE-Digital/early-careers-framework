# frozen_string_literal: true

desc "Appropriate bodies scrape and load"
namespace :appropriate_bodies do
  desc "Update appropriate bodies"
  task update_csv: :environment do
    source_url = "https://www.gov.uk/government/publications/statutory-teacher-induction-appropriate-bodies/find-an-appropriate-body"
    types_map = {
      "local authority" => "local_authority",
      "teaching school hub" => "teaching_school_hub",
      "other" => "national",
    }

    csv_path = Rails.root.join("data/appropriate_bodies.csv")

    puts "Updating data/appropriate_bodies.csv from #{source_url}"
    CSV.open(csv_path, "wb") do |csv|
      csv << %w[name type]

      doc = Nokogiri::HTML5(URI.parse(source_url).open)
      doc.css("table th[scope='row']").each do |row|
        source_type = row.parent.css("td").first.text.downcase
        type = types_map[source_type]
        if type
          name = row.text
          csv << [name, type]
        end
      end
    end
  end
end
