# frozen_string_literal: true

module Mail
  class DeliveryRecorder
    def self.setup!(enabled:)
      Mail::Message.include(MessageExtension)
      ActionMailer::Base.register_observer(new(enabled:))
    end

    def initialize(enabled:)
      @enabled = enabled
    end

    def delivered_email(mail)
      return unless enabled?

      response = mail.delivery_method.response

      ApplicationRecord.transaction do
        email = Email.create!(
          id: response.id,
          from: response.content["from_email"],
          to: mail.original_to,
          template_id: response.template["id"],
          template_version: response.template["version"],
          uri: response.uri,
          tags: mail.tags,
          personalisation: mail.header["personalisation"]&.unparsed_value,
        )

        user_ids = User.where(email: email.to).pluck(:id) + ParticipantIdentity.where(email: email.to).pluck(:user_id)
        email.create_association_with(*User.where(id: user_ids).to_a, as: :recipient)

        mail.associations.each do |object, name|
          email.create_association_with object, as: name
        end
      end
    end

  private

    def enabled?
      !!@enabled
    end

    module MessageExtension
      def associations
        @associations ||= []
      end

      def tags
        @tags ||= []
      end

      def associate_with(*objects, as: nil)
        objects.each do |object|
          associations << [object, as]
        end
        self
      end

      def tag(*new_tags)
        tags.concat(new_tags)
        self
      end
    end
  end
end
