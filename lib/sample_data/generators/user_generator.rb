# frozen_string_literal: true

module SampleData
  module Generators
    class UserGenerator
      extend SampleData::Generators::Support::GeneratorClassUtil

      attr_reader :overrides, :user

      def initialize(**overrides)
        @overrides = overrides
      end

      def generate
        Rails.logger.debug("generating user")

        @user = User.create!(**attributes)

        self
      end

    private

      def attributes
        FactoryBot.attributes_for(:user).merge(overrides)
      end
    end
  end
end
