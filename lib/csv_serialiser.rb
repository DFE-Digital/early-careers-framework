# frozen_string_literal: true

class CSVSerialiser
  class << self
    def serialise(csv_serialisable)
      CSV.generate do |csv|
        csv << csv_serialisable.csv_headers
        csv_serialisable.to_csv.each do |csv_serialisable_row|
          csv << csv_serialisable_row.to_csv
        end
      end
    end
  end
end
