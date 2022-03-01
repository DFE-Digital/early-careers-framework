module Support
  module Identity
    def sign_in(user, *)
      identity = user.identities.first || user.identities.create!(email: user.email)
      super identity
    end

    RSpec.configure do |rspec|
      rspec.prepend self, type: :feature
      rspec.prepend self, type: :request
      rspec.prepend self, type: :controller
    end
  end
end
