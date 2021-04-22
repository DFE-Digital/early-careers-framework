module Support
  module RequestSpec
    class SessionHelperController < ActionController::Base
      def update
         session[params[:key]] = params[:value]
      end
    end

    Rails.application.routes.tap do |routes|
      routes.disable_clear_and_finalize = true
      routes.draw { post "__session", to: "support/request_spec/session_helper#update" }
      routes.disable_clear_and_finalize = false
    end

    def set_session(key, value)
      post "/__session", params: { key: key, value: value }
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :request
    end
  end
end
