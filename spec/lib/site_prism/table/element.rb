# frozen_string_literal: true

module SitePrism
  module Table
    class Element
      def initialize(html, definition)
        @doc = Nokogiri::HTML.parse(html)
        @definition = definition
      end

      def rows
        [].tap do |result|
          @doc.css(":root>body>tbody>tr, :root>body>tr").each do |row_in|
            row_out = {}
            row_in.css("td").each_with_index do |cell, i|
              name, options = @definition.columns[i]
              row_out[name] = cell.text.strip
              if options.include?(:format)
                row_out[name] = options[:format].call(row_out[name])
              end
            end
            result << row_out unless row_out.empty?
          end
        end
      end
    end
  end
end
