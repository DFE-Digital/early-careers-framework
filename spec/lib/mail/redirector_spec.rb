# frozen_string_literal: true

class MyMailer < ApplicationMailer
  attr_reader :from, :to, :user_name

  def hello
    @from = params[:our_email]
    @user_name = params[:user_name]
    @to = params[:user_email]

    mail(from:, to:, personalisation: { subject: "Hi" }) do |format|
      format.text { render plain: "Hello #{user_name}" }
    end
  end
end

RSpec.describe Mail::Redirector, type: :mailer do
  let(:subject_value) { "Hi" }
  let(:our_email) { Faker::Internet.email }
  let(:user_name) { Faker::Name.name }
  let(:user_email) { Faker::Internet.email }
  let(:mail) { MyMailer.with(our_email:, user_name:, user_email:).hello.deliver_now }

  context "testing environment" do
    it "do not modify emails sent" do
      expect(mail.from).to eq([our_email])
      expect(mail.to).to eq([user_email])
      expect(mail.body.encoded).to match("Hello #{user_name}")
    end
  end

  context "production environment" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
    end

    it "do not modify emails sent" do
      expect(mail.from).to eq([our_email])
      expect(mail.to).to eq([user_email])
      expect(mail.body.encoded).to match("Hello #{user_name}")
    end
  end

  context "environments other than testing or production" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    end

    context "when a redirection email address is not set on SEND_EMAILS_TO envar" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "do not modify emails sent" do
        expect(mail.from).to eq([our_email])
        expect(mail.to).to eq([user_email])
        expect(mail.body.encoded).to match("Hello #{user_name}")
      end
    end

    context "when a redirection email address is setup on SEND_EMAILS_TO envar" do
      let(:redirect_email) { Faker::Internet.email }

      before do
        ENV.stub(:[]).and_call_original
        ENV.stub(:[]).with("SEND_EMAILS_TO").and_return(redirect_email)
      end

      it "redirects the email" do
        expect(mail.from).to eq([our_email])
        expect(mail.to).to eq([redirect_email])
        expect(mail.body.encoded).to match("Hello #{user_name}")
      end

      it "keeps the original destination address in the header :original_to" do
        expect(mail.original_to).to eq([user_email])
      end
    end
  end
end
