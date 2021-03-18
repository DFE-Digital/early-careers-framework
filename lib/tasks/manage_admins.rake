# frozen_string_literal: true

desc "Manage admin users"
namespace :admin do
  desc "Create admin user"
  task :create, %i[full_name email] => :environment do |_task, args|
    include Rails.application.routes.url_helpers
    default_url_options[:host] = Rails.configuration.domain

    puts "Creating user"
    AdminProfile.create_admin(args[:full_name], args[:email], new_user_session_url)
    puts "User created; email sent"
  end
end
