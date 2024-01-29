# frozen_string_literal: true

module Admin::Performance
  class SupportQueriesController < Admin::BaseController
    skip_after_action :verify_authorized, only: :show
    skip_after_action :verify_policy_scoped, only: :show

    def show
      @support_query_counts = SupportQuery.group(:subject).count.with_indifferent_access
      @support_query_user_counts = SupportQuery.where(id: SupportQuery.select("distinct on (user_id, subject) id")).group(:subject).count.with_indifferent_access
      @subjects = SupportQuery::VALID_SUBJECTS.sort # alphabetical
                                              .sort_by { |subject| 0 - (@support_query_counts[subject] || 0) } # most -> least
    end
  end
end
