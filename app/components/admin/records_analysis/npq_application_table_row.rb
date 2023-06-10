# frozen_string_literal: true

module Admin
  module RecordsAnalysis
    class NPQApplicationTableRow < BaseComponent
      with_collection_parameter :application

      def initialize(application:)
        @application = application
        @last_declaration = find_last_declaration
      end

    private

      attr_reader :application, :last_declaration

      def find_last_declaration
        application.profile.participant_declarations.where(state: %w[paid payable]).order(:created_at).first
      end
    end
  end
end
