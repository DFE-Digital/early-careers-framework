---
title: Lead providers
---

### Find schools delivering ECF-based training in a given cohort and view details of a specific school

Context:

---

Must specify a cohort in the request.

Successful request will show school details including school name,
URN, cohort, type of training programme they have chosen to deliver,
and whether they have confirmed partnerships in place for the
cohort/academic year.

API will only show schools that are eligible for funded ECF-based
training programmes within a given cohort. API will not show schools
that are ineligible for funding in a given cohort. If a school's
eligibility changes from one cohort to the next, results will default
according to the latest school eligibility.

This ensures providers can see up to date information on whether a
school is eligible for FIP and a potential partnership, and prevents
LPs being able to see details of schools that are ineligible for
funding.
Can filter results by school URN.
Can use school ID to find and view details for a specific school in a
cohort.

---

### Find delivery partner IDs and view details for a specific delivery partner

Context:

---

Successful request will show DP details including DP ID, name, and cohort(s) they are registered for.

Can filter results by cohort.

Can use DP ID to find and view details for a specific DP.
  

---
### Confirm a partnership with a school and delivery partner

Context: Must specify cohort, school ID and DP ID in the request.

---

Successful requests will return a response body with updates
included.

API assumes schools intend to work with a given provider for
consecutive cohorts. If a school user confirms existing partnership
with provider will continue into the upcoming cohort, providers do
not need take any action to continue existing partnerships from one
cohort to the next.

In order for new providers to confirm partnerships with schools for
an upcoming cohort, school users must first notify DfE that their
schools will not continue their former partnerships with existing
providers for the upcoming cohort. Until induction tutors have done
this, any new partnerships with new providers will be rejected by the
API.

---
### View all details for all existing partnerships or a specific existing partnership

Context:

---

View details of existing partnerships including cohort, school URN
and ID, DP ID and name, SIT name and email.

Details of partnership status are also shown:

-   Active - partnership between a provider, school and delivery
    partner has been agreed and confirmed by the provider. Providers
    can view, confirm and update active partnerships.

-   Challenged - partnership between a provider, school and delivery
    partner has been changed or dissolved by the school. Providers
    can only view challenged partnerships.

If partnership is challenged, the reason and date/time is also shown.

Can filter results by cohort.

Can use ID to find and view details of a specific existing
partnership.

---

### Update a partnership with a new delivery partner

Context: Use delivery partner ID to update

---

Partnerships can only be updated when the status is active (not challenged by the school).

---

### View all participant data or a specific participant's data

Context:

---

Successful requests will show participant details including name, TRN, training record ID, email, mentor ID, school URN, participant type, cohort, training status, participant status. 

Can filter results by cohort and updated since a date/time.

API will not present any data for participants whose details have not yet been validated by DfE.

Might come across duplicate participants -- DfE will retire one participant ID in this case.

Can use participant ID to find and view details of a specific participant.

Doesn't show unfunded mentors?
  
---

### View all unfunded mentor details (API v3 onwards)

Context:

---

A single mentor can be assigned to multiple ECTs, including ECTs who are training with other providers. 'Unfunded mentors' are mentors who are registered with other providers. These mentors may need access to the learning platforms used by their ECTs.

Successful requests will return a response body with mentor details of unfunded mentors who are currently assigned to ECTs, including the mentor's participant ID, name, email and TRN.

Can use participant ID to find and view details of a specific unfunded mentor.
  
---

### Notify DfE a participant has taken a break (deferred) from training

Context: Participant can take a break from training (with intention to return) at any time, and LP must notify DfE in response.

---

Use participant ID to update training status to deferred.

Report reason for deferral.
  
---

### Notify DfE a participant has resumed training

Context:

---

Deferred participants can resume training at any time, and LP must notify DfE in response.

Use participant ID to update training status to active.

---

### Notify DfE a participant has withdrawn from training

Context: Participant can withdraw from training at any time and LP must notify DfE in response.

---

Use participant ID to update training status to withdrawn.

Submitted declarations will only be paid if declaration date is before the date of the withdrawal.

---

### Notify DfE of a participant's training schedule

Context: All participants are registered by default to a standard schedule starting in September.

---

LPs must notify DfE if a different schedule is needed using the participant ID.

Schedule can't be changed if the participant has any previously submitted eligible, payable or paid declarations with a declaration_date which does not align with the new schedule's milestone dates. In this case the LP can void the relevant declarations, then change the schedule and resubmit backdated declarations.
  
--- 

### View data for all participants who have transferred or a specific participant (API v3 onwards)

Context: When school reports a transfer, LP can view data for participants who have transferred to or from a school they are partnered with.

---

When a participant is leaving them and this has been reported by the old school and/or new school, LP can see an updated participant status of leaving and the details of the end / start date depending on what has been reported by the schools.

When a participant is joining them and this has been reported by the old school and/or the new school, LP can see an updated participant status of leaving and the details of the end / start date depending on what has been reported by the schools.

When transfer is complete, the old provider should report the participant as withdrawn from training to DfE.

Can find and view a specific participant who has transferred.
  
---

### Update a replacement mentor's schedule

Context:

---

A new mentor can be assigned to an ECT part way through training, replacing the ECT's original mentor.

Providers must notify the DfE of replacement mentors by updating their training schedule.

If a replacement mentor is already mentoring another ECT and they replace a mentor for a second ECT, the first ECT takes precedence. In this instance, the provider should not change the mentor's schedule.

For API v3 onwards, a replacement mentor's schedule, and any associated declaration submissions, do not need to align with the ECT they are mentoring.

---
### Test the ability to submit declarations in sandbox ahead of time

Context:

Use the service to do the same tasks with the same rules as above with test data.
  
---

### Submit a declaration to notify DfE a participant has started, been retained, or completed training

Context:
  
---
### View all previously submitted declarations

Context:

---

### View a specific previously submitted declaration

Context:

---

### Void or clawback a declaration

Context:

---

### View specific statement payment dates or all statement payment dates

Context:

---

## CSV upload service

[CSV upload is accessed here](https://manage-training-for-early-career-teachers.education.gov.uk/lead-providers/partnership-guide)

### Sign in to the Manage ECTs service

Context:

---

Individual nominated to access the service

When user enters the registered email into the service login page, an email is sent to their email with a magic sign in link to sign into the service.

---

### Confirm partnerships with schools

Context:

---

Upload a separate CSV list of schools for each DP who will be working
with them.

CSV must include one (first) column with school URNs, with a new
school on each row and no empty rows between URNs and no other data.
Partnership will not be confirmed if:

-   School already recruited and confirmed by another provider

-   URN not valid

-   School already confirmed and is on the provider's list

-   School not eligible for inductions as per our GIAS list of
    eligible schools

-   School not eligible for funding from DfE (they can only do CIP)

-   School programme not yet confirmed -- SIT has not yet logged into
    the service to confirm if they will deliver training using a
    DfE-funded training provider this year and/or will continue with
    their current provider.

Can continue with any schools that don't have errors, or can update
the CSV and reupload.

School sent an email on confirmation, which includes a link to
challenge the partnership if it is incorrect.

If partnership is reported as incorrect, LPs can't receive payment
for that school.

Email will be sent to LP when school challenges the partnership and
notification will be shown to LP in the service, including the reason
the partnership was challenged.

Further contact with the school to resolve the issue will be offline
outside of the service.

If school challenged the parentship incorrectly, LP can reupload the
school in a CSV again.

---

### View ECT, mentor and SIT details

Context:

---

Can view list of schools LP has a confirmed partnership with.
  
Can view total number of schools recruited.

Can view details of partnered schools, including school name, URN and induction tutor contact information.

Can search for a school in a specific cohort?

Can see total number of ECTs and mentors added by each school
  
--- 

### Contact support or provide feedback on the service

Context: Users may need to access support whilst using the API.

---

Can email
<continuing-professional-development@digital.education.gov.uk> or can
use Slack channels.

* 🙋 This is to allow users to access support for any issue or query
they may have with the service.

---

Can complete [feedback
form](https://forms.office.com.mcas.ms/Pages/ResponsePage.aspx?id=yXfS-grGoU2187O4s0qC-YkKKgAihPhLr_Bqhw1DVMZUMjlKMU4xRlNCTUk0WEVTVTdOVDNMUDFWWCQlQCN0PWcu)
(same form as for school users) in the CSV upload service.

* 💻 This follows the [Gov.uk service manual for measuring user
satisfaction](https://www.gov.uk/service-manual/measuring-success/measuring-user-satisfaction).

---

### View API guidance

Context: LPs can view guidance on how to use the API for managing ECF
training.

---

User can view guidance on how to use the API.

* 🙋 This is to provide an overview of how LPs can use the API and
what they need to report.

--- 

User can view details of updates to the API.

* 🙋 This is to ensure LPs are informed of any changes that happen
with how the API works.
