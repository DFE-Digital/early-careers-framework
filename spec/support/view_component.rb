# frozen_string_literal: true

require_relative "view_component/stubbing_helper"

module Support
  module ViewComponent
    extend ActiveSupport::Concern

    included do
      subject(:rendered) { render_inline component }
      let(:component) { described_class.new }
    end

    class_methods do
      def component(&block)
        let(:component, &block)
      end

      def request_path(url)
        around do |example|
          with_request_url(url) do
            example.run
          end
        end
      end
    end

    delegate :t, :translate, to: :component

    RSpec.configure do |rspec|
      rspec.include ::ViewComponent::TestHelpers, type: :view_component
      rspec.include StubbingHelper, type: :view_component
      rspec.include self, type: :view_component
      rspec.include Capybara::RSpecMatchers, type: :view_component
    end
  end
end
