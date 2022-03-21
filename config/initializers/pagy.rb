# frozen_string_literal: true

require "pagy/extras/overflow"

# Return an empty page when page number too high (other options :last_page and :exception )
Pagy::DEFAULT[:overflow] = :empty_page
