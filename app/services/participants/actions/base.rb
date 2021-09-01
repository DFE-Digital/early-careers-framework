# frozen_string_literal: true

require "factories/course_identifier"

module Participants
  module Actions
    class Base
      attr_accessor :params

      class << self
        def call(params)
          new(params).call
        end

        def not_implemented_error
          raise NotImplementedError, "Method must be implemented"
        end

        delegate :recorder_namespace, to: :not_implemented_error
      end

      def call
        recorder = "#{self.class.recorder_namespace}::#{::Factories::CourseIdentifier.call(course_identifier)}".constantize
        recorder.call(params: params)
      end

      private

      def initialize(params)
        @params = params
      end

      def course_identifier
        params[:course_identifier]
      end

    end
  end
end
