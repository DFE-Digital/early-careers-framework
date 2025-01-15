# frozen_string_literal: true

module Mail
  module Notify
    module MailersController
      def preview
        @email_action = File.basename(params[:path])
        return super unless @preview.email_exists?(@email_action)

        @email = @preview.call(@email_action, params)

        return super unless notify?

        return render_part if params[:part]

        render_preview_wrapper
      end

      private

      def render_part
        # Add the current directory to the view path so that Rails can find
        # the `govuk_notify_layout` layout
        append_view_path(__dir__)

        response.content_type = "text/html"
        render html: @email.preview.html.html_safe, layout: "govuk_notify_layout"
      end

      def render_preview_wrapper
        @part = @email
        render action: "email", layout: false, formats: %i[html]
      end

      def notify?
        @email.delivery_method.instance_of?(Mail::Notify::DeliveryMethod)
      end
    end
  end
end
