# frozen_string_literal: true

require "mail/personalisation"
require "mail/redirector"
require "mail/delivery_recorder"

ActionMailer::Base.register_interceptor(Mail::Personalisation)
ActionMailer::Base.register_interceptor(Mail::Redirector)
Mail::DeliveryRecorder.setup!(enabled: Rails.application.config.record_emails)
