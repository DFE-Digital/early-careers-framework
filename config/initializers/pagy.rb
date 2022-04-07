# frozen_string_literal: true

require "pagy/extras/overflow"
require "pagy/extras/array"

# Return an empty page when page number too high (other options :last_page and :exception )
Pagy::DEFAULT[:overflow] = :empty_page
