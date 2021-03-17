# frozen_string_literal: true

desc "Manage admin users"
namespace :admin do
  desc "Create admin user"
  task :create, %i[full_name email] => :environment do |_task, args|
    include Rails.application.routes.url_helpers
    default_url_options[:host] = Rails.configuration.domain

    puts "Creating user"
    user = User.new(full_name: args[:full_name], email: args[:email])
    user.confirm

    ActiveRecord::Base.transaction do
      user.save!
      AdminProfile.create!(user: user)
      AdminMailer.account_created_email(
        user, new_user_session_url
      ).deliver_now
    end
    puts "User created; email sent"
  end
end
