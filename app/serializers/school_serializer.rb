# frozen_string_literal: true

class SchoolSerializer < Blueprinter::Base
  identifier :id
  fields :full_address_formatted, :name
end
