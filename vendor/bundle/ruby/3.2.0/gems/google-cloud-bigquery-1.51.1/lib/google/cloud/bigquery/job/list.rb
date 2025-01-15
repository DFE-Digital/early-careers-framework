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
      class Job
        ##
        # Job::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          # A hash of this page of results.
          attr_accessor :etag

          ##
          # @private Create a new Job::List with an array of jobs.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of jobs.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   jobs = bigquery.jobs
          #   if jobs.next?
          #     next_jobs = jobs.next
          #   end
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of jobs.
          #
          # @return [Job::List]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   jobs = bigquery.jobs
          #   if jobs.next?
          #     next_jobs = jobs.next
          #   end
          def next
            return nil unless next?
            ensure_service!
            next_kwargs = @kwargs.merge token: token
            next_gapi = @service.list_jobs(**next_kwargs)
            self.class.from_gapi next_gapi, @service, **next_kwargs
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
          #   make to load all jobs. Default is no limit.
          # @yield [job] The block for accessing each job.
          # @yieldparam [Job] job The job object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each job by passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigquery.jobs.all do |job|
          #     puts job.state
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   all_states = bigquery.jobs.all.map do |job|
          #     job.state
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigquery.jobs.all(request_limit: 10) do |job|
          #     puts job.state
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
          # @private New Job::List from a Google API Client
          # Google::Apis::BigqueryV2::JobList object.
          def self.from_gapi gapi_list, service, **kwargs
            jobs = List.new(Array(gapi_list.jobs).map { |gapi_object| Job.from_gapi gapi_object, service })
            jobs.instance_variable_set :@token,    gapi_list.next_page_token
            jobs.instance_variable_set :@etag,     gapi_list.etag
            jobs.instance_variable_set :@service,  service
            jobs.instance_variable_set :@kwargs,   kwargs
            jobs
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
