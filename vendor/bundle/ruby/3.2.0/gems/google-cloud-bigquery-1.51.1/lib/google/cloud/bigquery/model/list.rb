# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "delegate"

module Google
  module Cloud
    module Bigquery
      class Model
        ##
        # Model::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          ##
          # @private Create a new Model::List with an array of models.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of models.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   models = dataset.models
          #   if models.next?
          #     next_models = models.next
          #   end
          #
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of models.
          #
          # @return [Model::List]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   models = dataset.models
          #   if models.next?
          #     next_models = models.next
          #   end
          #
          def next
            return nil unless next?
            ensure_service!
            gapi = @service.list_models @dataset_id, token: token, max: @max
            self.class.from_gapi gapi, @service, @dataset_id, @max
          end

          ##
          # Retrieves remaining results by repeatedly invoking {#next} until
          # {#next?} returns `false`. Calls the given block once for each
          # result, which is passed as the argument to the block.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results
          # are retrieved. (Unlike `#each`, for example, which merely iterates
          # over the results returned by a single API call.) Use with caution.
          #
          # @param [Integer] request_limit The upper limit of API requests to
          #   make to load all models. Default is no limit.
          # @yield [model] The block for accessing each model.
          # @yieldparam [Model] model The model object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each result by passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.models.all do |model|
          #     puts model.model_id
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   all_names = dataset.models.all.map do |model|
          #     model.model_id
          #   end
          #
          # @example Limit the number of API requests made:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.models.all(request_limit: 10) do |model|
          #     puts model.model_id
          #   end
          #
          def all request_limit: nil, &block
            request_limit = request_limit.to_i if request_limit
            return enum_for :all, request_limit: request_limit unless block_given?
            results = self
            loop do
              results.each(&block)
              if request_limit
                request_limit -= 1
                break if request_limit.negative?
              end
              break unless results.next?
              results = results.next
            end
          end

          ##
          # @private New Model::List from a response object.
          def self.from_gapi gapi_list, service, dataset_id = nil, max = nil
            models = List.new(Array(gapi_list[:models]).map { |gapi_json| Model.from_gapi_json gapi_json, service })
            models.instance_variable_set :@token,      gapi_list[:nextPageToken]
            models.instance_variable_set :@service,    service
            models.instance_variable_set :@dataset_id, dataset_id
            models.instance_variable_set :@max,        max
            models
          end

          protected

          ##
          # Raise an error unless an active service is available.
          def ensure_service!
            raise "Must have active connection" unless @service
          end
        end
      end
    end
  end
end
