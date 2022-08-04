# frozen_string_literal: true

# The job Admin::ApplicationExportJob has been replaced with Admin::NPQApplications::ExportJob
# To ensure that already enqueued and unfinished jobs are not affected this alias is in place
#
# This should be removed once the deployment is complete and the queue has been confirmed clear
# of any Admin::ApplicationExportJob jobs
Admin::ApplicationExportJob = Admin::NPQApplications::ExportJob
