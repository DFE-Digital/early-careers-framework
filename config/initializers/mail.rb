# frozen_strin_literal: true

require 'mail/delivery_recorder'
require "mail/redirector"


ActionMailer::Base.register_interceptor(Mail::Redirector)
Mail::Message.include(Mail::Redirector::MessageExtension)
ActionMailer::Base.register_observer(Mail::DeliveryRecorder)
