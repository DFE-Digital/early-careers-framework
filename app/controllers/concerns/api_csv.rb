# frozen_string_literal: true

module ApiCsv
private

  def to_csv(hash)
    return "" if hash[:data].empty?

    headers = %w[id]
    attributes = hash[:data].first[:attributes].keys
    headers.concat(attributes.map(&:to_s))
    CSV.generate(headers: headers, write_headers: true) do |csv|
      hash[:data].each do |item|
        row = [item[:id]]
        row.concat(attributes.map { |attribute| item[:attributes][attribute].to_s })
        csv << row
      end
    end
  end
end
