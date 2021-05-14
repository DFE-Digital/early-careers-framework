# frozen_string_literal: true

module Support
  module RequestSpec
    class SessionHelperController < ApplicationController
      respond_to :json

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
      post "/__session", params: { key: key, value: value }.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :request
    end
  end
end
