# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

api_token = ARGV[0] || "HAPPY FEET"
url_blue = ARGV[1] || "https://ecf-review-pr-2604.london.cloudapps.digital/api/v1/ecf-users"  # current
url_green = ARGV[2] || "https://ecf-review-pr-2604.london.cloudapps.digital/api/v1/ecf-users" # new

def get_data(uri, api_token)
  url = URI.parse(uri)

  request = Net::HTTP::Get.new(url.request_uri)
  request["User-Agent"] = "CPD API Smoke Tester"
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{api_token}"

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  response = http.request(request)

  raise "#{response.message} for #{uri}" unless response.is_a? Net::HTTPSuccess

  data = JSON.parse(response.body, symbolize_names: true)[:data]
  data.each { |hash| hash[:attributes] = hash[:attributes].sort.to_h }
  data.sort_by { |hash| hash[:id] }
  data
end

blue_data = get_data(url_blue, api_token)
green_data = get_data(url_green, api_token)

deduped_records = []
green_data.each do |record|
  deduped_records << record if deduped_records.filter { |r| r[:id] == record[:id] }.count.zero?
end

same_records = green_data.filter do |record|
  blue_data.filter { |r| r[:id] == record[:id] }.count == 1
end

new_records = green_data.filter do |record|
  blue_data.filter { |r| r[:id] == record[:id] }.count.zero?
end

lost_records = blue_data.filter do |record|
  green_data.filter { |r| r[:id] == record[:id] }.count.zero?
end

console.log "blue_records: #{blue_data.count}"
console.log "green_records: #{green_data.count}"
console.log "duplicates_found: #{green_data.count - deduped_records.count}"
console.log "matches: #{same_records.count}"
console.log "new: #{new_records.count}"
console.log "lost: #{lost_records.count}"
