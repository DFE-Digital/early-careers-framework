# frozen_string_literal: true

return unless defined?(::Rails::Generators)

module RailsGeneratorFrozenStringLiteralPrepend
  RUBY_EXTENSIONS = %w[.rb .rake].freeze

  def render
    return super unless RUBY_EXTENSIONS.include? File.extname(destination)

    "# frozen_string_literal: true\n\n" + super
  end
end

Thor::Actions::CreateFile.prepend RailsGeneratorFrozenStringLiteralPrepend
