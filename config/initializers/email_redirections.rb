require 'email_redirector'
ActionMailer::Base.register_interceptor(EmailRedirector)
