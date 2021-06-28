# frozen_string_literal: true

require "gias_api_client"
require "csv"

module DataStage
  class FetchGiasDataFiles < ::BaseService
    def call
      files = {
        school_data_file: school_data_file,
        school_links_file: school_links_file,
      }

      if block_given?
        yield files
      else
        # potentially unsafe as underlying Tempfiles maybe removed if object goes out of scope
        files
      end
    end

  private

    def school_data_file
      gias_files["ecf_tech.csv"].path
    end

    def school_links_file
      gias_files["links.csv"].path
    end

    def gias_files
      @gias_files ||= gias_api_client.get_files
    end

    def gias_api_client
      @gias_api_client ||= GiasApiClient.new
    end
  end
end
