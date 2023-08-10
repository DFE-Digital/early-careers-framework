# frozen_string_literal: true

require "participant_profile_deduplicator"

module Finance
  module ECF
    module Duplicates
      class CompareController < BaseController
        before_action :load_profiles, :set_breadcrumbs
        before_action :set_dry_run

        def show; end

        def deduplicate
          dedup!

          if @dry_run
            render :show
          else
            flash[:success] = {
              title: "Profiles deduplicated",
              content: @dedup_changes.join("<br>"),
            }
            redirect_to finance_ecf_duplicates_path
          end
        end

      private

        def dedup!
          deduplicator = ParticipantProfileDeduplicator.new(@primary_profile.id, @duplicate_profile.id, dry_run: @dry_run)
          @dedup_changes = deduplicator.dedup!
          @can_deduplicate = true
        rescue ParticipantProfileDeduplicator::DeduplicationError => e
          @dedup_changes = [e.message]
        end

        def set_dry_run
          @dry_run = ActiveModel::Type::Boolean.new.cast(params[:dry_run] || true)
        end

        def load_profiles
          @primary_profile = Duplicate.find(params[:id] || params[:compare_id])
          @duplicate_profile = Duplicate.find(params[:duplicate_id])
        end

        def set_breadcrumbs
          @breadcrumbs = [
            helpers.govuk_breadcrumb_link_to("Finance dashboard", finance_landing_page_path),
            helpers.govuk_breadcrumb_link_to("Search records", finance_ecf_duplicates_path),
            helpers.govuk_breadcrumb_link_to(@primary_profile.user.full_name, finance_ecf_duplicate_path(@primary_profile)),
            helpers.govuk_breadcrumb_link_to("Details", finance_ecf_duplicate_compare_path(@duplicate_profile, @primary_profile)),
          ]
        end
      end
    end
  end
end
