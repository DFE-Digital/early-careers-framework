# Copyright 2015 Google LLC
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
      class Dataset
        ##
        # Dataset::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          # A hash of this page of results.
          attr_accessor :etag

          ##
          # @private Create a new Dataset::List with an array of datasets.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of datasets.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   datasets = bigquery.datasets
          #   if datasets.next?
          #     next_datasets = datasets.next
          #   end
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of datasets.
          #
          # @return [Dataset::List]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   datasets = bigquery.datasets
          #   if datasets.next?
          #     next_datasets = datasets.next
          #   end
          def next
            return nil unless next?
            ensure_service!
            gapi = @service.list_datasets all: @hidden, filter: @filter, token: token, max: @max
            self.class.from_gapi gapi, @service, @hidden, @filter, @max
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
          #   make to load all datasets. Default is no limit.
          # @yield [dataset] The block for accessing each dataset.
          # @yieldparam [Dataset] dataset The dataset object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each result by passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigquery.datasets.all do |dataset|
          #     puts dataset.name
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   all_names = bigquery.datasets.all.map do |dataset|
          #     dataset.name
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigquery.datasets.all(request_limit: 10) do |dataset|
          #     puts dataset.name
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
          # @private New Dataset::List from a response object.
          def self.from_gapi gapi_list, service, hidden = nil, filter = nil, max = nil
            datasets = List.new(Array(gapi_list.datasets).map { |gapi_object| Dataset.from_gapi gapi_object, service })
            datasets.instance_variable_set :@token,   gapi_list.next_page_token
            datasets.instance_variable_set :@etag,    gapi_list.etag
            datasets.instance_variable_set :@service, service
            datasets.instance_variable_set :@hidden,  hidden
            datasets.instance_variable_set :@filter,  filter
            datasets.instance_variable_set :@max,     max
            datasets
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
