# frozen_string_literal: true

# The model NPQApplicationExport has been renamed to NPQApplications::Export
# To ensure that already enqueued and unfinished jobs are not affected this alias is in place
#
# This should be removed once the deployment is complete and the queue has been confirmed clear
# of any jobs using NPQApplicationExport
NPQApplicationExport = NPQApplications::Export
