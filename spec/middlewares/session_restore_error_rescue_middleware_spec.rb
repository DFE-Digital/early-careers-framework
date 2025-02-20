# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionRestoreErrorRescueMiddleware do
  let(:session_key) { Rails.application.config.session_options[:key] }
  let(:session_id) { "f2cea1a7bd96a923a778d474cca911e8" }
  let(:session_private_id) { Rack::Session::SessionId.new(session_id).private_id }
  let(:session_data) { { user_id: 42 } }
  let(:session) { ActiveRecord::SessionStore::Session.create!(session_id: session_private_id, data: session_data) }

  let(:env) do
    {
      "HTTP_COOKIE" => "#{session_key}=#{session_id}; other_cookie=bar",
      "rack.session" => session_data,
      "rack.session.options" => { expire_after: 3600 },
    }
  end

  let(:app) do
    lambda do |env|
      req = ActionDispatch::Request.new(env)

      # Try loading current session
      begin
        session_id = req.cookies[session_key]
        private_id = Rack::Session::SessionId.new(session_id).private_id
        ActiveRecord::SessionStore::Session.find_by(session_id: private_id)&.data
      rescue ArgumentError
        raise ActionDispatch::Session::SessionRestoreError
      end

      [200, env, %w[OK]]
    end
  end

  before do
    # Create random sessions
    3.times do
      ActiveRecord::SessionStore::Session.create!(
        session_id: Rack::Session::SessionId.new(SecureRandom.uuid).private_id,
        data: { test: 123 },
      )
    end

    # Create this session
    session
  end

  context "when no session restore error is raised" do
    it "calls the downstream app and returns its response unchanged" do
      expect(ActiveRecord::SessionStore::Session.count).to eq(4)

      middleware = described_class.new(app)
      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(body).to eq(%w[OK])

      req = ActionDispatch::Request.new(headers)
      expect(req.env["rack.session"]).to eq({ user_id: 42 })
      expect(req.env["rack.session.options"]).to eq({ expire_after: 3600 })
      expect(req.cookies["other_cookie"]).to eq("bar")
      expect(req.cookies[session_key]).to eq(session_id)

      expect(ActiveRecord::SessionStore::Session.count).to eq(4)
      session.reload
      expect(session.data[:user_id]).to eq(42)
    end
  end

  context "when a SessionRestoreError is raised" do
    # A marshalled object "MadeUp", this class does not exist
    let(:bad_data) { "BAh7CUkiDnJldHVybl90bwY6BkVGSSI3aHR0cDovL2xvY2FsaG9zdDozMDAw\nL2ZpbmFuY2UvbWFuYWdlLWNwZC1jb250cmFjdHMGOwBUSSIQX2NzcmZfdG9r\nZW4GOwBGSSIwU2ZFdHZ6c096RmUwMmk5RTFsd1ZkdG5PejVTb3VzdHhoRDZX\nakZwcmxNbwY7AEZJIhl3YXJkZW4udXNlci51c2VyLmtleQY7AFRbB1sGSSIp\nZWEzODM0NTItYzNiMC00ZGMyLWIwMzMtOTUwNzhhYjYwYmE2BjsAVDBJIgl0\nZXN0BjsARm86K0ZpbmFuY2U6OkxhbmRpbmdQYWdlQ29udHJvbGxlcjo6TWFk\nZVVwAA==\n" }

    it "rescues the error, deletes bad session" do
      expect(ActiveRecord::SessionStore::Session.count).to eq(4)

      # Inject bad data into session store
      ActiveRecord::SessionStore::Session.where(id: session.id).update_all(data: bad_data)

      middleware = described_class.new(app)
      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(body).to eq(%w[OK])

      req = ActionDispatch::Request.new(headers)
      expect(req.env["rack.session"]).to eq({ user_id: 42 })
      expect(req.env["rack.session.options"]).to eq({ expire_after: 3600 })
      expect(req.cookies["other_cookie"]).to eq("bar")
      expect(req.cookies[session_key]).to eq(session_id)

      expect(ActiveRecord::SessionStore::Session.count).to eq(3)
      expect(ActiveRecord::SessionStore::Session.find_by(id: session.id)).to be_nil
    end
  end
end
