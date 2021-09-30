# frozen_string_literal: true

ActionMailer::Base.default_url_options[:host] ||= Rails.application.config.domain
