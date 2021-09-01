# frozen_string_literal: true

desc "Manage admin users"
namespace :admin do
  desc "Create admin user"
  task :create, %i[full_name email] => :environment do |_task, args|
    puts "Creating user"
    sign_in_url = Rails.application.routes.url_helpers.new_user_session_url(
      host: Rails.configuration.domain,
      **UTMService.email(:new_admin),
    )

    AdminProfile.create_admin(args[:full_name], args[:email], sign_in_url)
    puts "User created; email sent"
  end
end
