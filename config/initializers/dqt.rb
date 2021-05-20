# frozen_string_literal: true

Dqt.configure do |config|
  def json_to_hash(json)
    JSON.parse(json.gsub("=>", ":"), symbolize_names: true)
  end

  config.client.headers = { Authorization: Rails.application.config.dqt_client_api_key }
  config.client.host = Rails.application.config.dqt_client_host
  config.client.params = json_to_hash(Rails.application.config.dqt_client_params)
end
