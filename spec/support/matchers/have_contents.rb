# frozen_string_literal: true

module Support
  module HaveContents
    extend RSpec::Matchers::DSL

    define :have_contents do |*contents|
      match do |actual|
        begin
          aggregate_failures "have_contents" do
            contents.each { |content| expect(actual).to have_content content }
          end
        rescue RSpec::Expectations::MultipleExpectationsNotMetError => e
          @exception = e
          raise
        end

        true
      end

      failure_message do |*_args|
        @exception.message.lines[2..-1].join
      end
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :view_component
      rspec.include self, type: :view
    end
  end
end
