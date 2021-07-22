# frozen_string_literal: true

desc "Manage admin users"
namespace :users do
  namespace :finance do
    desc "Create finance user"
    task :create, %i[full_name email] => :environment do |_task, args|
      puts "Creating finance user..."
      CreateFinanceUser.call(args[:full_name], args[:email])
      puts "User created."
    end
  end
end
