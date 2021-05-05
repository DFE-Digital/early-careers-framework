# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request do
  path "/users" do
    get "Returns all users" do
      operationId :public_api_v1_user_index
      tags "user"
      produces "application/json"

      response "200", "Collection of users." do
        schema type: :object,
               properties: {
                 users: {
                   type: :array,
                   items: {
                     properties: {
                       id: { type: :string },
                       email: { type: :string },
                       full_name: { type: :string },
                     },
                     required: %w[id email full_name],
                   },
                 },
               }
        run_test!
      end
    end
  end
end
