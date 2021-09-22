# frozen_string_literal: true

require "mail/redirector"
require "mail/delivery_recorder"

ActionMailer::Base.register_interceptor(Mail::Redirector)
Mail::Message.include(Mail::Redirector::MessageExtension)

Mail::DeliveryRecorder.enable!
