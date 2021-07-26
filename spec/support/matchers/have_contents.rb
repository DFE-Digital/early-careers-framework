# frozen_string_literal: true

module Support
  module HaveContents
    extend RSpec::Matchers::DSL

    define :have_contents do |*contents|
      match do |actual|
        check_contents!(contents)

        begin
          aggregate_failures "have_contents" do
            contents.each { |content| expect(actual).to have_content content }
          end
        rescue RSpec::Expectations::ExpectationNotMetError, RSpec::Expectations::MultipleExpectationsNotMetError => e
          @exception = e
          raise
        end

        true
      end

      match_when_negated do |actual|
        check_contents!(contents)

        begin
          aggregate_failures "have_contents" do
            contents.each { |content| expect(actual).not_to have_content content }
          end
        rescue RSpec::Expectations::ExpectationNotMetError, RSpec::Expectations::MultipleExpectationsNotMetError => e
          @exception = e
          raise
        end

        true
      end

      failure_message do |*_args|
        case @exception
        when RSpec::Expectations::MultipleExpectationsNotMetError then @exception.message.lines[2..-1].join
        else @exception.message
        end
      end

      def check_contents!(contents)
        unless contents.all?
          indexes = contents.map.with_index { |content, index| index if content.blank? }.compact
          raise "Cannot test on content presence of `nil` - at #{indexes.join(', ')}"
        end
      end
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :view_component
      rspec.include self, type: :view
    end
  end
end
