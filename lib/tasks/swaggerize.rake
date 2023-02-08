# frozen_string_literal: true

if defined?(RSpec)
  require "rspec/core/rake_task"

  Rake::Task["rswag:specs:swaggerize"].clear

  namespace :rswag do
    namespace :specs do
      desc "Generate Swagger JSON files from integration specs"
      RSpec::Core::RakeTask.new('swaggerize') do |t|
        t.pattern = ENV.fetch(
          'PATTERN',
          'spec/docs/**/*_spec.rb'
        )

        additional_rspec_opts = ENV.fetch(
          'ADDITIONAL_RSPEC_OPTS',
          ''
        )

        t.rspec_opts = [additional_rspec_opts]

        if Rswag::Specs.config.swagger_dry_run
          t.rspec_opts += ['--format Rswag::Specs::SwaggerFormatter', '--dry-run', '--order defined']
        else
          t.rspec_opts += ['--format Rswag::Specs::SwaggerFormatter', '--order defined']
        end
      end
    end
  end
end
