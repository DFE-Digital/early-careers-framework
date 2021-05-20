# frozen_string_literal: true

require "email_redirector"
ActionMailer::Base.register_interceptor(EmailRedirector)
