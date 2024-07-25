# frozen_string_literal: true

require Rails.root.join("config/environments/sandbox")

Rails.application.configure do
  # Enable/disable aspects of the separation environment
  config.npq_separation = {
    disable_npq_endpoints: true,
  }
end
