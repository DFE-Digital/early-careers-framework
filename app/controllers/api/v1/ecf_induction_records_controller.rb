# frozen_string_literal: true

module Api
  module V1
    class ECFInductionRecordsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

      def index
        render json: ECFInductionRecordSerializer.new(paginate(induction_records)).serializable_hash.to_json
      end

      def create
        user = Identity.find_user_by(email: params[:data][:attributes][:email])

        if user.present?
          user.errors.add(:email, :taken)

          hash = {
            errors: [{
              status: "409",
              title: user.errors.full_messages.join(", "),
            }],
          }

          render json: hash, status: :conflict and return
        end

        user = User.create!(
          email: params[:data][:attributes][:email],
          full_name: params[:data][:attributes][:full_name],
        )

        hash = UserSerializer.new(user).serializable_hash

        render json: hash, status: :created
      end

    private

      def access_scope
        ApiToken.where(private_api_access: true)
      end

      def email
        filter[:email]
      end

      def induction_records
        induction_records = InductionRecord.current
                                           .joins(:induction_programme, :preferred_identity, :participant_profile)
                                           .merge(ParticipantProfile.ecf)

        induction_records = induction_records.where("induction_records.updated_at > ?", updated_since) if updated_since.present?
        induction_records = induction_records.where(preferred_identity: { email: }) if email.present?

        induction_records
      end
    end
  end
end
