# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

api_token = ARGV[0] || "API-TOKEN"
url_blue = ARGV[1] || "https://localhost:3000/api/v1/ecf-users" # current
url_green = ARGV[2] || "https://localhost:3000/api/v1/ecf-induction-records" # new

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

if new_records.count.zero? && lost_records.count.zero?
  puts "The API responses are the same"
else
  puts "ERROR: The API responses are different"
  puts "blue_records: #{blue_data.count}"
  puts "green_records: #{green_data.count}"
  puts "duplicates_found: #{green_data.count - deduped_records.count}"
  puts "matches: #{same_records.count}"
  puts "new: #{new_records.count}"
  puts "lost: #{lost_records.count}"
  exit 1
end
