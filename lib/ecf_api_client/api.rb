require "ecf_api_client/client"
require "uri_template"
class ECFApiClient
  class API
    include Singleton

    GET_PARTICIPANTS_ENDPOINT   = "/api/v1/participants/ecf".freeze
    POST_DECLARATION_ENDPOINT   = "/api/v1/participant-declarations".freeze
    CHANGE_SCHEDULE_ENDPOINT    = "/api/v1/participants/ecf/{id}/change-schedule".freeze
    RECORD_DECLARATION_ENDPOINT = "/api/v1/participant-declarations".freeze

    def initialize
      self.client = Client.new
    end

    class << self
      delegate :participants, :change_schedule, :participant_declaration, to: :instance
    end

    def participant_declaration(participant_id:, declaration_type:, declaration_date:, course_identifier:)
      params = {
        type: "participant-declaration",
        attributes: {
          participant_id: participant_id,
          declaration_type: declaration_type,
          declaration_date: declaration_date.rfc3339,
          course_identifier: course_identifier,
        },
      }
      client.pool.with do |http|
        http.post(RECORD_DECLARATION_ENDPOINT, { data: params })
      end
    end

    def participants
      client.pool.with do |http|
        http.get(GET_PARTICIPANTS_ENDPOINT).body["data"].map do |p|
          Participant.from(p)
        end
      end
    end

    def change_schedule(id:, schedule_identifier:, course_identifier:, cohort: "2021")
      params = {
        type: "participant-change-schedule",
        attributes: {
          schedule_identifier: schedule_identifier,
          course_identifier: course_identifier,
          cohort: cohort,
        },
      }
      client.pool.with do |http|
        http.put(url_for(CHANGE_SCHEDULE_ENDPOINT, id: id), { data: params })
      end
    end

    private
    attr_accessor :client

    def url_for(uri, params)
      URITemplate.new(uri, params).expand(params)
    end
  end
end
