# frozen_string_literal: true

module Support
  module RequestSpec
    class SessionHelperController < ApplicationController
      respond_to :json

      def update
        value = params.require(:value)
        value = value.to_unsafe_hash if value.respond_to?(:to_unsafe_hash)
        session[params[:key]] = value
      end
    end

    def set_session(key, value)
      post "/__session", params: { key: key, value: value }.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :request
    end
  end
end
