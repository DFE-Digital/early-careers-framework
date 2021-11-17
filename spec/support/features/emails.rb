# frozen_string_literal: true

module FeatureEmails
  extend ActiveSupport::Concern

  included do
    around do |example|
      session = Capybara.current_session
      original = ActionMailer::Base.default_url_options
      ActionMailer::Base.default_url_options = { host: session.config.server_host, port: session.config.server_port }.freeze

      example.run
    ensure
      ActionMailer::Base.default_url_options = original
    end
  end

  RSpec.configure do |rspec|
    rspec.include self, type: :feature
  end
end
