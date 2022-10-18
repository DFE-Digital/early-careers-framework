# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "json-diff"

api_token = ARGV[0] || "API-TOKEN"
url_blue = ARGV[1] || "http://localhost:3000/api/v1/ecf-users" # current
url_green = ARGV[2] || "http://localhost:3000/api/v1/ecf-induction-records" # new

def get_data(uri, api_token)
  url = URI.parse(uri)

  request = Net::HTTP::Get.new(url.request_uri)
  request["User-Agent"] = "CPD API Smoke Tester"
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{api_token}"

  http = Net::HTTP.new(url.host, url.port)
  # http.use_ssl = true
  response = http.request(request)

  raise "#{response.message} for #{uri}" unless response.is_a? Net::HTTPSuccess

  data = JSON.parse(response.body, symbolize_names: true)[:data]
  data.each { |hash| hash[:attributes] = hash[:attributes].sort.to_h }
  data.sort_by { |hash| hash[:id] }
  data
end

blue_data = get_data(url_blue, api_token)
green_data = get_data(url_green, api_token)

duplicate_records = green_data.tally.filter { |_, v| v > 1 } # assuming we're counting the number of duplications rather than duplicated records
same_records      = (blue_data & green_data)
new_records       = green_data - same_records
lost_records      = blue_data - same_records

if new_records.count.zero? && lost_records.count.zero?
  puts "The API responses are the same"
else
  puts "ERROR: The API responses are different"
  puts "Blue records: #{blue_data.count}"
  puts "Green records: #{green_data.count}"
  puts "Duplicates found: #{duplicate_records.count}"
  puts "Matches: #{same_records.count}"
  puts "Changed: #{(new_records - lost_records).count}"
  puts "New: #{(new_records - (new_records - lost_records)).count}"
  puts "Lost: #{(lost_records - (lost_records - new_records)).count}"

  new_records.each do |before|
    id = before[:id]
    after = lost_records.filter { |record| record[:id] == id }.first
    puts "\n\nExpected to find\n"
    puts JsonDiff.diff(before, after, include_was: true).map { |el| "    #{el['path']}: \"#{el['was']}\"" }.join("\n")
    puts "\nwithin:\n===\n#{JSON.pretty_generate(after)}"
  end

  exit 1
end
