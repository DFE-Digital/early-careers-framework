# frozen_string_literal: true

require_relative "./base"

module Pages
  class CheckAccountPage < ::Pages::Base
    set_url "/check-account"
    set_primary_heading "How to access this service"

    def send_school_link
      # /nominations/resend-email > Send your school a link
    end

    def register_for_ect_training
      # /participants/start-registration > Register for your early career teacher training now
    end
  end
end
