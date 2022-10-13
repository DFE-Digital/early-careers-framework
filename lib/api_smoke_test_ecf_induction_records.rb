# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

api_token = "HAPPY FEET"
domain = "ecf-review-pr-2604.london.cloudapps.digital"

def get_data(uri, api_token)
  url = URI.parse(uri)

  request = Net::HTTP::Get.new(url.request_uri)
  request["User-Agent"] = "CPD API Smoke Tester"
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{api_token}"

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  response = http.request(request)

  data = JSON.parse(response.body, symbolize_names: true)[:data]
  data.each { |hash| hash[:attributes] = hash[:attributes].sort.to_h }
  data.sort_by { |hash| hash[:id] }
  data
end

users_data = get_data("https://#{domain}/api/v1/ecf-users", api_token)
ir_data = get_data("https://#{domain}/api/v1/ecf-induction-records", api_token)

ir_deduped = []
ir_data.each do |ir_record|
  if ir_deduped.filter { |record| record[:id] == ir_record[:id] }.count.zero?
    ir_deduped << ir_record
  end
end

# IR record in user records
same_records = ir_data.filter do |ir_record|
  found = users_data.filter { |record| record[:id] == ir_record[:id] }
  found.count == 1
end

# IR record not user records
new_records = ir_data.filter do |ir_record|
  found = users_data.filter { |record| record[:id] == ir_record[:id] }
  found.count.zero?
end

# User record not IR records
lost_records = users_data.filter do |user_record|
  found = ir_data.filter { |record| record[:id] == user_record[:id] }
  found.count.zero?
end

Rails.logger.debug "user_records"
Rails.logger.debug users_data.count
Rails.logger.debug "ir_records"
Rails.logger.debug ir_data.count
Rails.logger.debug "ir_deduped"
Rails.logger.debug ir_deduped.count
Rails.logger.debug "same"
Rails.logger.debug same_records.count
Rails.logger.debug "new"
Rails.logger.debug new_records.count
Rails.logger.debug "lost"
Rails.logger.debug lost_records.count
