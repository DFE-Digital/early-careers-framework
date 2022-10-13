# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

def get_data(uri)
  url = URI.parse(uri)

  request = Net::HTTP::Get.new(url.request_uri)
  request["User-Agent"] = "CPD API Smoke Tester"
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer HAPPY FEET"

  http = Net::HTTP.new(url.host, url.port)
  response = http.request(request)

  data = JSON.parse(response.body, symbolize_names: true)[:data]
  data.each { |hash| hash[:attributes] = hash[:attributes].sort.to_h }
  data.sort_by { |hash| hash[:id] }
  data
end

users_data = get_data("http://localhost:3000/api/v1/ecf-users")
ir_data = get_data("http://localhost:3000/api/v1/ecf-induction-records")

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

puts "user_records"
puts users_data.count
puts "ir_records"
puts ir_data.count
puts "ir_deduped"
puts ir_deduped.count
puts "same"
puts same_records.count
puts "new"
puts new_records.count
puts "lost"
puts lost_records.count
