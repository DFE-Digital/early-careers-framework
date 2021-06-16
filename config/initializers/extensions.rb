# frozen_string_literal: true

Dir.glob(Rails.root.join("lib/extensions/**/*.rb")).sort.each do |extension|
  require extension
end
