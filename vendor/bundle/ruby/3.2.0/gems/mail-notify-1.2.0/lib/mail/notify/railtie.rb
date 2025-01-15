# frozen_string_literal: true

require "rails/mailers_controller"

module Mail
  module Notify
    class Railtie < Rails::Railtie
      initializer "mail-notify.add_delivery_method", before: "action_mailer.set_configs" do
        ActionMailer::Base.add_delivery_method(:notify, Mail::Notify::DeliveryMethod)
      end

      initializer "mail-notify.action_controller" do
        ActiveSupport.on_load(:action_controller, run_once: true) do
          Rails::MailersController.prepend(Mail::Notify::MailersController)
        end
      end
    end
  end
end
