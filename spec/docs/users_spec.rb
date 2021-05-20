# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:token) { EngageAndLearnApiToken.create_with_random_token! }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/users" do
    get "Returns all users" do
      operationId :api_v1_user_index
      tags "user"
      produces "application/vnd.api+json"
      security [bearerAuth: []]

      response "200", "Collection of users." do
        schema type: :object,
               required: %w[data],
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %w[id type attributes],
                     properties: {
                       id: { type: :string },
                       type: { type: :string },
                       attributes: {
                         type: :object,
                         required: %w[email full_name user_type core_induction_programme],
                         properties: {
                           email: { type: :string },
                           full_name: { type: :string },
                           user_type: {
                             type: :string,
                             enum: USER_TYPES.keys,
                           },
                           core_induction_programme: {
                             type: :string,
                             enum: CIP_TYPES.keys,
                           },
                         },
                       },
                     },
                   },
                 },
               }

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        run_test!
      end
    end
  end
end
