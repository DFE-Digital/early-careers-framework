---
title: School admins
---

This document currently covers the service rules for school admins.

School admins are also known as:

* school users
* school induction tutors (SITs)
* school induction coordinators

## Request access to the Manage ECTs service via school GIAS email

Context: For schools to use the Manage ECTs service, they first need to
register. This functionality is used both for schools who are using the
service for the first time as well as schools that can no longer access
the service via their existing SIT email (e.g. SIT has left).

---

To register, the user must identify the school in our [GIAS register
subset](https://github.com/DFE-Digital/early-careers-framework/blob/main/app/models/concerns/gias_helpers.rb#L8)
using local authority (LA) and school name. The school must be open
and either an eligible establishment type and/or in England. If
school can't be found in the GIAS list, they can't request a link to
access the service.

* 📊 The GIAS register is used in order to check that the school is
real. This is the most up to date list of schools available, with
most of the details we need to check schools' eligibility to have
ECTs serve induction.

* 📜 School eligibility requirements for accessing the service come
  from the [statutory guidance](https://github.com/DFE-Digital/ecf2/blob/main/documentation/policy/induction-for-early-career-teachers.adoc#institutions-in-which-induction-may-be-served)
  which details the schools where ECTs can serve induction.

---

School URN and address are shown for the user to confirm the correct
school.

* 📊 These are publicly available, unique school details to help the
  user confirm we have identified the correct school.

---

GIAS email is shown in redacted form, including the first and last
letter of the username and the full domain name (i.e. <X****X@domain.com>).

* 🙋 Redacted email is shown to help schools identify where the GIAS
  email has been sent.

* 🔒 The email is redacted because GIAS email is not publicly
  available information.

---

GIAS email can't be changed within the service - if the GIAS email is
incorrect/out of date, school needs to update it using [DfE sign
in](https://services.signin.education.gov.uk/).

📊 GIAS is the source of truth for the school email and can be
updated via DfE Sign-in.
An email is sent to the school GIAS email on confirmation.

* 💻 This is to confirm that the person trying to access the service
legitimately works at the selected school if they can (indirectly)
access their school's GIAS email.

* 📊 GIAS email is the most direct and up to date contact we have for
schools (until SIT details are provided).

---

Anyone can trigger the link being sent to a school's GIAS email and
there is no limit on the number of times access can be requested.

* 💻 We don't know who specifically will need to access the service
before we are told by the school and the current process means we
don't / can't limit access for requesting the link to particular
people. There is no specific need to limit the number of times access
can be requested.

---

The link can be requested regardless of whether the school already
has a SIT nominated or not.

🙋 This is to account for schools where the existing SIT account can
no longer be accessed (see [design history](https://teacher-cpd.design-history.education.gov.uk/manage-training/re-nomination-journey/)).

---

## Nominate a school induction tutor (SIT)

Context: Schools are asked to nominate an individual as the 'induction
tutor' who will oversee the induction and training process to ensure
that ECTs and their mentors are effectively supported and guided through
induction. Part of this role is to use the manage ECTs service to give
details of their school's mentors, ECTs and training option to DfE to
enable delivery and funding for ECTP training.

---

Schools that say they are not expecting ECTs for the upcoming/current
(depending on when they access the service) academic year are not
asked to nominate a SIT or use the service to report any further
information.

* 💻 The data collected in the Manage ECTs service is not applicable
  to schools that aren't expecting ECTs, so we don't need the school to
  nominate a SIT user or sign into the service.

---

Schools that say they are expecting ECTs or are not sure yet must
nominate a SIT.

* 📜 This comes from the requirements in the [DfE guidance](https://www.gov.uk/guidance/how-to-set-up-training-for-early-career-teachers)
  that it is a SIT responsibility to use the service.
  Only one SIT can be nominated per school.

* 💻 UI for multiple user access is supported but not built. There is
  an assumption that only one person at the school will need to use the
  service.

---

Name and email address are provided to nominate the SIT.

* 💻 The email allows the nominated SIT to sign into the service. We
  also use their name and email as the contact for DfE comms.

---

There is a uniqueness validation on email address across all profiles
(SITs, ECTs and mentors). However, if both name and email address
match an existing record, this person can be registered as the SIT
for multiple schools.

* 💻 The uniqueness validation is to avoid the same email address
  being used for different people. The combined name and email match is
  to account for SIT who work across multiple schools (e.g. in a MAT).

---

An email is sent to the nominated SIT on confirmation.

* 💻 The user nominating the SIT may not be the SIT themselves, so the
  email notifies the nominated SIT and provides instructions for
  signing into the service.

---
Nominated SIT will be the email used for all further comms.

* 💻 Once nominated, the SIT becomes DfE's most direct point of
  contact with the school and is responsible for reporting early career teacher
  training details.

## Log in with an email address once nominated as SIT

Context: Once nominated, the SIT becomes the school's user for the
Manage ECTs service and must log in to use the service and report
early career teacher training details for their school.

If user enters a registered email address on the sign in page, they
are sent a magic sign in link via email which they can use to
directly log into the service.

* 💻 Magic sign in link approach was deemed to be the best approach at
the time of original build.

If the email address is not registered, the unregistered email is
sent an email to explain next steps.

* 🙋 This email was created to reduce the number of support requests
from people who couldn't remember if they had used the service before
or not, and people who couldn't remember which email was registered
(see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/emailing-users-who-try-to-sign-in-with-an-unregistered-email/)).
User must agree to privacy policy on first sign in.

* 🔒 It is a GDPR requirement to inform users of how DfE will use
their data.

## Manage multiple schools with one email address

Context: Some SITs may work across multiple schools (e.g. in a Multi Academy Trust or MAT), and
they can manage their multiple schools using the same email login for
the service.

---

Multiple schools can nominate the same induction tutor if both name
and email address match an existing record.

* 💻 This is to account for SITs that may work across multiple schools
(e.g. in a MAT).

---

When signed into the service, the user can select between which of
their schools they would like to manage. They can only manage a
school one at a time.

* 💻 The service was not built with this use case in mind.

---

## Change the SIT

Context: Only one SIT user per school can use the service at a time, and
this person can be changed and replaced by someone else at the school if
needed (e.g. if they leave the school, change role).

User can change the nominated SIT and replace themselves with a
different person by changing both nominated SIT name and email.

* 💻 This is to allow the SIT to be updated when there is a change in
role or the existing SIT leaves.

User can change their own registered email by entering the same name
and changing the email only.

There isn't an explicit journey built to change details of the
existing SIT (existing functionality is used as a hack).
There is a uniqueness validation on email address across all SITs,
ECTs and mentors. However, if both name and email address match an
existing SIT record, this person can be registered as the SIT for
multiple schools.

* 💻 The uniqueness validation is to avoid the same email address
being used for different people. The combined name and email match is
to account for SITs who work across multiple schools (e.g. in a
MAT).

The user cannot change their own name whilst keeping their existing
email.

When a user changes the SIT details, they immediately lose access to the
SIT dashboard.

* 💻 UI for multiple user access is supported but not built. There is
an assumption that only one person at the school will need to use the
service.

An email is sent to the new nominated SIT on confirmation.

* 💻 This email is to notify the new nominated SIT and provides
instructions for signing into the service.

New nominated SIT will be the email used for all further comms.

* 💻 Once nominated, the SIT becomes DfE's most direct point of
contact with the school and is responsible for reporting ECTP
training details.

## Select and change the school induction programme

Context: Each year, the SIT must report / confirm their 'default'
programme choice for the academic year.

When registrations open, if user says they are expecting ECTs they
must report a 'default' programme for the new academic year.

* 🙋 Most schools choose the same programme for all their ECTs in a
particular year (with exceptions for things like transfers), so we
ask schools to choose a 'default' which is used for any new ECTs
rather than asking the user to select the same thing for each of
their ECTs individually.

---

If a school induction tutor chose FIP and had a partnership reported in the directly
previous academic year, they are shown the names of the LP and DP
they were working with and can rollover their previous programme and
partnership choice.

* 📜 The policy intent is for schools to continue with the FIP
programme and the same LP/DP where possible.

---

If user chose FIP in the previous academic year and LP/DP pairing has
changed, they must re-select programme choice for the new academic
year.


* 📚 Some LP/DP contracts change year to year which means schools may
not be able to continue working with the same pairing for the
following year (see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/supporting-schools-in-lp-dp-transition/)).

--- 

If user chose FIP but didn't have a partnership reported in the
directly previous academic year, they must re-select programme choice
for the new academic year.

* 💻 There is no pairing to rollover.

---

LP is emailed if school is not able to automatically rollover their
previous partnership due to a change in LP/DP pairing.

* 💻 If school reports that they're doing FIP again, the service
treats it as a rejection of the partnership and triggers an email to
the LP. This flags to the LP that if they are still working with the
school with a new DP then they need to let us know which DP.

--- 

If user chose CIP, DIY, or didn't have a programme choice in the
previous academic year, they must select their programme choice for the new
academic year.

* 🙋 The rollover mechanism was built for FIP as this was relevant to
the majority of schools and helped speed up the registration journey
for these schools. It was not an active choice to not let CIP and DIY
schools rollover.

---

Once user has submitted their programme choice for an academic year,
they must contact support to change the choice.

* 💻 This was not a deliberate rule, there is no strong policy
reason. Note, LP can override the programme choice by reporting a
partnership. As long as the school has a cohort set up for that year,
this sets the programme choice to FIP for that school.

---

If school is CIP only, they can only select CIP or DIY options.

* 📜 Only state-funded schools, colleges, sixth forms, children's
centres and nurseries, maintained and non-maintained special schools,
and independent schools that receive Section 41 funding are not
eligible for DfE funded training (see [DfE
guidance](https://www.gov.uk/guidance/funding-and-eligibility-for-ecf-based-training)).
Other schools can access the service for CIP materials, or
self-funded FIP.

---

Once default programme choice is selected for an academic year, new
ECTs and mentors in that year will be set to use this programme when
registered.

* 🙋 This is to reflect how things work on the ground. The majority
of schools with multiple ECTs will be doing the same programme.

---

## Appoint and change Appropriate Body for a cohort or individual ECT

Context: Schools must appoint an appropriate body (outside of the Manage
ECTs service) for their ECTs. We ask SITs to report their AB choice(s)
to DfE via the Manage ECTs service. It is not a statutory need to report
within the service -- in fact it needs to be reported outside of the service. Use
the info to play the details back to the ABs -- to cross reference check
where schools have registered ECTs for training without registering for
induction. On their records they can also see the other way round --
might mean they've not filled in the AB or not registered the ECT at
all.

--- 

SITs can report who they have appointed as their AB for an academic
year, but they don't have to.

* 📜 Schools that will deliver any form of ECF-based training (FIP,
CIP or DIY) must appoint an AB for each of their ECTs. Schools can
choose whether to appoint one appropriate body for all of their ECTs,
or different ones.

* 📚 Schools should report to DfE who the AB is for each of their
ECTs from a defined list of organisations that can act as an AB for
each cohort. This is to enable ABs to cross check that ECTs have been
registered for both induction and training.

---

The list of ABs that can be appointed is updated each year. Some ABs can no longer be appointed going forwards or be used for existing
cohorts / participants (see [2024
changes](https://educationgovuk.sharepoint.com/:w:/r/sites/TeacherServices/Shared%20Documents/Teacher%20Continuing%20Professional%20Development/Teacher%20CPD%20Team/11.%20Provider%20Engagement%20%26%20Policy/ECF/2024%20cohort/AB%20list%20for%202024/AB%20changes%20to%20reflect%20before%202024%20registration%20opens.docx?d=w201a5f2247b541b3a401112eba53c099&csf=1&web=1&e=yrSkid)).

All schools can appoint a teaching school hub from the hardcoded list in the service.

Independent schools only can also appoint [Independent Schools Teacher Induction Panel](https://istip.co.uk/)
(ISTIP).

British schools overseas only can also appoint Educational Success Partners (ESP).

* 📜 [DfE
guidance](https://assets.publishing.service.gov.uk/media/661d459fac3dae9a53bd3de6/Appropriate_bodies_guidance_induction_and_the_early_career_framework.pdf)
sets out the organisations that can or cannot act as an AB. From September 2024, Teaching school hubs will become the main appropriate
body providers -- details can be found on
[gov.uk](https://www.gov.uk/guidance/teaching-school-hubs). We get the list for the service from policy -- there are 3 lists on gov.uk
so policy give us the exact names.

* 📊 Presenting only the eligible options to different types of
schools in the service aims to improve data accuracy ([design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/improving-how-we-capture-appropriate-body-information/)).

---

## View and challenge partnerships for an academic year

Context: FIP schools choose a lead provider and delivery partner to deliver training for their
ECTs. Once this agreement between the school and LP has been made outside of the Manage ECTs service, LPs report this partnership via the
API.

--- 

The nominated SIT email is used to log into the service. When a SIT enters the registered email into the service login page, an email is sent to
their email with a magic sign in link to sign into the service.

* 💻 Magic link approach was decided to be the best sign in option at the time.

---

When LP has reported a partnership with a school, LP and DP name are shown in the SIT dashboard.

* 📚 As schools do not report partnerships themselves, showing the partnership as reported by the LP allows schools to see if the details are as expected.

* 💻 The provider reporting the partnership journey (rather than
schools) was easier to build originally.

---

Partnership can only be challenged during the first two weeks after
it has been reported (if at another time of year), or in the first 3
months of the academic year. This voids the partnership.

* 💻 This is to allow schools to correct provider errors. For example
in some cases a provider can jump the gun and report a partnership
when the school is actually speaking to multiple providers about
forming a partnership still.

* 💻 The challenge window is limited because schools can cause
problems and impact declarations when they challenge a partnership.

---

There can only be one 'default' partnership for an academic year. LP
can't claim a school if they already have a partnership -- school
needs to challenge the existing partnership first.

* 📚 Original assumption that everyone at a school would be doing the
same thing -- exceptions added later (smaller numbers). Choices for
each year are now less relevant -- we know schools' preference is to
shift all participants, including those mid training, when a LP/DP
pairing changes.

---

<!-- FIXME: check this, how long is the challenge window? -->
After, the lead provider and delivery partner cannot be changed without
contacting support.

* 💻 The challenge window is limited because schools can cause
problems and impact declarations when they challenge a partnership.

---

## Add an ECT

Context: SITs are asked to register any new ECTs each year and provide
details to enable DfE to check their eligibility for funding and pass
details of ECTs to LPs to facilitate access to training.

---

Schools must have selected a default programme choice for an academic
year to be able to add an ECT for that year.

* 🙋 Most schools choose the same programme for all their ECTs in a
particular year (with exceptions for things like transfers), so we
ask schools to choose a 'default' which is used for any new ECTs
rather than asking the user to select the same thing for each of
their ECTs individually.

---

Identify the teacher in TRA using their TRN and DOB and confirm the
match by comparing their name. If there are no matches try
re-matching with the inclusion of National Insurance Number.

* 📚 This is to enable DfE to check eligibility for funding (see
section below).

* 🙋 SIT enters these details on behalf of ECTs as this caused
confusion and delays when previously entered by the ECTs themselves
(see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/validation-information/)).

---

If we can identify the participant in TRA, we check first name
matches. If name doesn't match, we ask if they are known by a
different name until there is a match.

* 📜 This is to enable real ECTs to register for training as part of
statutory induction.

* 📚 This is to enable DfE to check eligibility for funding (see
section below).

---

If a teacher can't be found in the DQT, they cannot be added as an
ECT.

* 💻 This prevents ECTs being added with incorrect details that may
never be validated. This was previously allowed and required lots of
manual checks.

---

Name and email address is also provided when an ECT is added.

* 🙋 This is to pass the details onto the LPs for onboarding to their
learning platform & invitations to training events. We also pass this
over for external evaluations (this is in the privacy policy).
There is a uniqueness validation on email addresses -- identities
have a unique constraint and users have a unique constraint.

* 💻 The uniqueness validation is to avoid the same email address
being used for different people.

* 💻 Identity records were brought in to allow multiple emails and to
help with deduping.

---

When the school has a default AB recorded, we ask SIT to confirm the ECT's
AB. SIT can confirm the AB is the same as the default, or select a different
AB.

The SIT can select a teaching school hub from the hardcoded list in the
service. Independent schools only can also appoint the [Independent Schools Teacher Induction Panel](https://istip.co.uk/)
(ISTIP). British schools overseas only can also appoint [Educational Success Partners](https://www.espeducation.co.uk/) (ESP).

* 📜 Schools that will deliver any form of ECF-based training (FIP,
CIP or DIY) must appoint an AB for each of their ECTs. Schools can
choose whether to appoint one appropriate body for all of their ECTs,
or different ones.

* 📚 Schools should report to DfE who the AB is for each of their
ECTs from a defined list of organisations that can act as an AB for
each cohort.

* 📜 [DfE guidance](https://assets.publishing.service.gov.uk/media/661d459fac3dae9a53bd3de6/Appropriate_bodies_guidance_induction_and_the_early_career_framework.pdf)
sets out the organisations that can or cannot act as an AB. We get
the list for the service from policy -- there are 3 lists on gov.uk
so policy give us the exact names.

* 📊 Presenting only the eligible options to different types of
schools in the service aims to improve data accuracy ([design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/improving-how-we-capture-appropriate-body-information/)).
ECTs for an academic year can be added once registrations open for
that academic year, and then anytime throughout the year afterwards.

---

* 📚 Participants must be added to a cohort, and can't be registered
until that cohort is set up in the service, because they have to be
associated with a contract / funding pot.

* 🙋 Schools may already know in summer which ECTs will be joining for
the following year, and then participants may join at any time
throughout the academic year.

---

An email is sent to the participant informing them they've been
registered.

* 🙋 This was originally because ECTs had to enter information
themselves but SITs now enter all the information on their behalf.

* 🔒 This is to provide participants with the privacy policy, and set
expectations about hearing from the provider.
When the teacher is added, they're checked against the DQT for if
they have QTS (or other relevant qualification) and an induction
start date that has been provided from the appropriate body portal.

---

ECTs can be added even if they don't yet have QTS, but they won't
appear as eligible to LPs.

* 📚 QTS is used to confirm the ECT's eligibility for funding, and the
induction start date is used to confirm the correct cohort
allocation.

* 🙋 School may want to register their incoming ECTs before they have
finished their ITT.

---

If a teacher is registered as a mentor in the service, they cannot be
added as an ECT.

* 📜 DfE only fund one set of training at a time, this was agreed at
ECF working group.
If school has selected FIP or CIP but not added any mentors or ECTs,
SIT is sent an email reminder.

* 💻 This is to ensure schools that are expecting ECTs have registered
their participants to enable access to training.

---

## Transfer in an ECT

Context: Some ECTs transfer schools during induction, which may also
involve changing their training option/LP/AB. We ask SITs to reflect
these changes in the Manage ECTs service to ensure the correct payments
are made.

---

Schools must have selected a default programme choice for an academic
year to be able to transfer in an ECT for that year.

* 🙋 Most schools choose the same programme for all their ECTs in a
particular year (with exceptions for things like transfers), so we
ask schools to choose a 'default' which is used for any new ECTs
rather than asking the user to select the same thing for each of
their ECTs individually.

---

If ECT identified in TRA is already registered at another school in
the service during ECT registration, user asked to confirm that they
are transferring the ECT into their school.

* 💻 This allows us to retain the ECT's participant profile so we know
what training they have completed, which is captured in the history
of declarations received (see [design history](https://teacher-cpd.design-history.education.gov.uk/manage-training/facilitating-participants-moving-schools-during-their-induction/)).

* 📚 This ensures we only pay providers what they are owed for the
training they delivered to the participant based on the payment
milestones.

---

Specify date ECT will be transferring in, which can be in the past or
future.

* 💻 This is used to trigger a change in status for the ECT in the SIT
dashboard. The date will also trigger the ECT to show as no longer
training at the old school.

---
User can choose to continue with ECT's LP/DP from previous school or
switch to new LP/DP (either the school's default LP or other).

* 📜 There is a policy preference / assumption that it's in ECTs best
interest to continue with the same provider. This was previously a
DfE recommendation, but now watered down and schools tend to have a
stronger preference to have all their participants with the same
provider, including transfers.

---

User can change ECT's email address as part of transfer in. In this
case both email addresses are associated with the participant.

* 🙋 Participants usually get a new email address when they move to a
new school. We need up to date emails because we pass this over for
external evaluations (this is in the privacy policy) and give emails
to LPs.

---

If a teacher is registered as a mentor in the service, they cannot be
added as an ECT.

* 📜 DfE only fund one set of training at a time - this was agreed at
ECF working group.

---

An email is sent to the participant informing them they've been
registered.

* 🔒 This is to provide participants with the privacy policy, and set
expectations about hearing from the provider.
LPs is emailed on reporting of transfer.

* 🙋 Before API v3, it was more difficult to see the details around
transfers, so provider emails were sent to notify them of transfers.
These may no longer be needed now.

---

On the joining date, ECT is shown as 'left' at their previous school.

* 💻 We assume that the ECT is no longer working at their previous
school if a new school has claimed them. We don't support ECTs
working across multiple schools.

---

On the joining date, ECT is unpaired from any mentor they were paired
with at previous school.

* 💻 We assume that the ECT will no longer be mentored by the mentor
at their previous school, so remove the pairing.

---

## Change an existing ECT's details (from ECT profile)

Context: SITs are able to change certain details of registered ECTs to
account for errors and genuine changes in details.

---

User can change ECT name.

SIT can change name if it's due to the ECT having changed their
name (marriage, divorce etc) or their name was entered
incorrectly. SIT blocked from changing name if they say the ECT
shouldn't have been registered or they want to replace them with
a different person.

ECT must not have completed induction and must not have left the
school for the SIT to be able to change name. There is an option
to contact support if the ECT has completed or left.

We allow changing the whole name.

* 🙋 ECT may have a name change or have an error in the entered name.

* 💻 We ask why an ECT's name needs changing because SITs were
previously using this functionality as a 'hack' for replacing an
existing ECT with a different person in the service.

* 💻 Allowing changing whole name creates a risk that users could
still overwrite a record with a different person as we don't
revalidate.

---

SIT can change ECT email.

ECT must not have completed induction and must not have left the
school for the SIT to be able to change email. There is an option
to contact support if the ECT has completed or left.

There is a uniqueness validation on email addresses.

* 📚 ECT may have a change to their email address -- we need up to
date emails because we pass this over for external evaluations (this
is in the privacy policy) and give emails to LPs.

* 🙋 Some people might register with personal emails first because
they don't have a school email yet, so need to change it later.

* 💻 The uniqueness validation is to avoid the same email address
being used for different people.

---

User can change AB.

ECT must not have completed induction and must not have left the
school for the SIT to be able to change AB.

SITs can add/change the AB for an individual ECT -- the AB for
individual can be the same or different to the default for their
cohort.

All schools can appoint a teaching school hub from the hardcoded
list in the service

Independent schools only can also appoint ISTIP

British schools overseas only can also appoint ESP

* 🙋 This is to let users correct details where they may have
initially entered the wrong one / struggled with the journey.

* 📜 Schools that will deliver any form of ECF-based training (FIP,
CIP or DIY) must appoint an AB for each of their ECTs. Schools can
choose whether to appoint one appropriate body for all of their ECTs,
or different ones.

* 📜 [DfE guidance](https://assets.publishing.service.gov.uk/media/661d459fac3dae9a53bd3de6/Appropriate_bodies_guidance_induction_and_the_early_career_framework.pdf)
sets out the organisations that can or cannot act as an AB. We get
the list for the service from policy -- there are 3 lists on gov.uk
so policy give us the exact names.

* 📚 Schools should report to DfE who the AB is for each of their
ECTs from a defined list of organisations that can act as an AB for
each cohort.

* 📊 Presenting only the eligible options to different types of
schools in the service aims to improve data accuracy ([design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/improving-how-we-capture-appropriate-body-information/)).

---

User cannot change TRN, DoB, or LP without contacting support.

* 💻 TRN and DOB are used to validate the participant, so the
participant needs to be re-validated when changing these details. A
way to re-validate participants automatically in the service hasn't
been built so is done manually via support.

## View ECT eligibility / training status

Context: Registered ECTs are shown to SITs in the Manage ECTs service to
allow them to view details and manage any changes.

---

SITs can view and filter ECTs who are currently training, completed induction
and no longer training.

* 🙋 This is to allow users to easily find the ECTs their looking for
(see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/filtering-early-career-teachers/))

---

SITs can view ECT induction start date. We do not show ECT cohorts.

* 🙋 This is to allow users to easily see which stage an ECT is at
without showing cohorts as this was found to be confusing (see
[design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/sorting-by-induction-start-date/)).

---

## Add a mentor

Context: All ECTs must be assigned a mentor as part of their statutory
induction. Mentors must be registered and assigned in the Manage ECTs
service for schools to get funding for mentor time off timetable and to
provide mentors access to their ECT's materials. FIP mentors are also
entitled to mentor training and associated funding for schools and
providers.

---

Schools must have selected a default programme choice for an academic
year to be able to add a mentor for that year.

* 🙋 Most schools choose the same programme for all their participants
in a particular year (with exceptions for things like transfers), so
we ask schools to choose a 'default' which is used for any new
mentors rather than asking the user to select the same thing for each
of their mentors individually.

---

Mentor must have a TRN to be registered. If mentor doesn't already
have a TRN, they can request one outside the service:
<https://www.gov.uk/guidance/teacher-reference-number-trn>

* 📚 This is to enable DfE to check against TRA records that the
mentor does not have any prohibitions, sanctions or restrictions on
their record, and to check eligibility for funding (see section
below).

---

Identify the teacher in TRA using their TRN and DOB and confirm the
match by comparing their name. If there are no matches try
re-matching with the inclusion of National Insurance Number.

* 📚 This is to enable DfE to check against TRA records that the
mentor does not have any prohibitions, sanctions or restrictions on
their record, and to check eligibility for funding (see section
below).

* 🙋 SIT enters these details on behalf of mentors as this caused
confusion and delays when previously entered by the mentors
themselves (see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/validation-information/)).

---

If a teacher can't be found in the DQT, they cannot be added as a
mentor.

* 📚 This is because we can't check against TRA records that the
mentor does not have any prohibitions, sanctions or restrictions on
their record, and we can't check eligibility for funding (see section
below).

---

If we can identify the participant in TRA, we check first name
matches. If name doesn't match, we ask if they are known by a
different name until there is a match.

* 📚 This is to enable DfE to check against TRA records that the
mentor does not have any prohibitions, sanctions or restrictions on
their record, and to check eligibility for funding (see section
below).
There is a uniqueness validation on email addresses.

* 💻 The uniqueness validation is to avoid the same email address
being used for different people.
A SIT can add themselves as a mentor using the same journey.

* 📜 [DfE
guidance](https://www.gov.uk/guidance/how-to-set-up-training-for-early-career-teachers#nominate-an-induction-tutor)
encourages schools to separate the roles of SIT and mentor, but they
can still add themselves if needed (see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/changing-how-induction-tutors-add-themselves-as-a-mentor/)).

---

If school has a default provider recorded, we ask SIT to confirm the
mentor's provider for mentor training.

* 📚 Triggered if school has more than one LP? In 2023 there
were ~1100 cases where because the mentor was set to the default
provider, they were training with a different provider to their ECT
(where there were different providers for different cohorts). We had
to check this was correct via providers.

---

Mentors for an academic year can be added once registrations open for
that academic year, and then anytime throughout the year afterwards.

* 📚 Participants must be added to a cohort, and can't be registered
until that cohort is set up in the service. This is so they can be
associated with a contract / funding pot.

* 🙋 Schools may already know in summer who will be acting as a mentor
for the following year, and then new mentors may start mentoring at
any time throughout the academic year.

---

An email is sent to the participant informing them they've been
registered. This isn't sent if the mentor is also a registered SIT.

* 🔒 This is to provide participants with the privacy policy, and set
expectations about hearing from the provider.

---

Mentor may or may not be doing mentor training.

* 📜 FIP mentors can complete 2 years of funded mentor training.
Mentors don't have to complete this training.

## Transfer in a mentor

Context: Some mentors transfer schools each year. We ask SITs to reflect
these changes in the Manage ECTs service to ensure the correct payments
are made.

---

Schools must have selected a default programme choice for an academic
year to be able to transfer in a mentor for that year.

* 🙋 Most schools choose the same programme for all their participants
in a particular year (with exceptions for things like transfers), so
we ask schools to choose a 'default' which is used for any new
mentors rather than asking the user to select the same thing for each
of their mentors individually.

---

If mentor identified in TRA is already registered at another school
in the service during mentor registration, user is asked to confirm
that they are transferring the mentor into their school.

* 💻 This allows us to retain the mentor's participant profile so we
know what training they have completed, which is captured in the
history of declarations received (see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/facilitating-participants-moving-schools-during-their-induction/)).

* 📚 This ensures we only pay providers what they are owed for the
training they delivered to the participant based on the payment
milestones.

---

Specify date mentor will be transferring in, which can be in the past
or future.

* 💻 This is used to trigger a change in status for the mentor in the
SIT dashboard.

---

On the leaving date, mentorship links with ECTs at the previous
school are removed and the mentor is no longer shown in the pool of
mentors.

* 💻 Unless the mentor is working across multiple schools, they are no
longer available to mentor ECTs at the school so are not shown in the
dashboard.

---

SIT is asked if the mentor is mentoring across multiple schools. If
yes, they must contact support to complete this. The mentor will show
in the list of mentors at both schools.

* 💻 The service wasn't built to account for this use case.

---

User can choose to continue with mentor's LP/DP from previous school
or switch to new LP/DP (either the school's default LP or other).

* 📜 Mentor can choose to continue mentor training without ECT.

---

User can change mentor's email address as part of transfer in.

* 🙋 Participants usually get a new email address when they move to a
new school.

---

An email is sent to the participant informing them they've been
registered

* 🔒 This is to provide participants with the privacy policy, and set
expectations about hearing from the provider.
It might also email the provider 

---

## Change an existing mentor's details (from mentor profile)

Context: SITs are able to change certain details of registered mentors
to account for errors and genuine changes in details.

---

User can change mentor name.

Mentor must not have left the school for the user to be able to
change their name. There is an option to contact support if the
mentor has left.

SIT can change name if it's due to the mentor having changed
their name (marriage, divorce etc) or their name was entered
incorrectly. SIT blocked from changing name if they say the
mentor shouldn't have been registered or they want to replace
them with a different person.

We allow changing the whole name.

* 🙋 Mentor may have a name change or have an error in the entered
name.

* 💻 We ask why an ECT's name needs changing because SITs were
previously using this functionality as a 'hack' for replacing an
existing ECT with a different person in the service.

* 💻 Allowing changing whole name creates a risk that users could
still overwrite a record with a different person as we don't
revalidate.

---

User can change mentor email.

Mentor must not have left the school for the SIT to be able to
change email. There is an option to contact support if the mentor
has left.

There is a uniqueness validation on email addresses.

* 📚 Mentor may have a change to their email address -- we need up to
date emails because we pass this over for external evaluations (this
is in the privacy policy) and give emails to LPs.

* 🙋 Some people might register with personal emails first because
they don't have a school email yet, so need to change it later.

* 💻 The uniqueness validation is to avoid the same email address
being used for different people.

---

User cannot change TRN, DoB, or LP without contacting support.

* 💻 TRN and DOB are used to validate the participant, so the
participant needs to be re-validated when changing these details. A
way to re-validate participants automatically in the service hasn't
been built so is done manually via support.

---

## View mentor mentoring status / training completion status

Context: Registered mentors are shown to SITs in the Manage ECTs service
to allow them to view details and manage any changes.

---

View mentors who are currently mentoring and not mentoring.

* 🙋 This is to allow users to more easily find the mentors their
looking for.

---

## Create and change mentorship links between ECTs and mentors

Context: All ECTs must be assigned a mentor to support them during their
induction.

---

User can assign a mentor to an ECT in the ECT registration journey,
the mentor registration journey or after an ECT and mentor are
registered in the SIT dashboard.

* 📜 All ECTs must be assigned a mentor during their induction (see
[statutory guidance](https://assets.publishing.service.gov.uk/media/6629237f3b0122a378a7e6ef/Induction_for_early_career_teachers__England__statutory_guidance_.pdf)).

* 🙋 The design aims to encourage users to assign a mentor to any ECTs
who do not yet have one assigned (see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/assigning-ects-to-mentors/)).

---

Mentor must be registered in the service in the same school as the
ECT to be available as a mentor for an ECT. Note, mentors may be in
the mentor pool at more than one school.

* 💻 The service was built on the assumption that a mentor would
always be at the same school as their assigned ECT.

---

Any registered mentor at the same school can be assigned to any ECT
who doesn't already have a mentor assigned. ECT can only be assigned
one mentor at a time.

* 📜 ECTs must have a dedicated mentor, but there is no limit on
having other additional mentors.

* 📚 DfE commercial decision not to pay for time off timetable for
additional mentors.

---

There is no limit on the number of ECTs a mentor can be assigned to.

* 📜 Whilst there is no specific limit, [DfE statutory
guidance](https://assets.publishing.service.gov.uk/media/6629237f3b0122a378a7e6ef/Induction_for_early_career_teachers__England__statutory_guidance_.pdf)
sets out that mentors should be able to support an ECT, and too many
pairings would impact a mentor's capacity to do that.
Mentor may or may not be doing mentor training.

* 📜 Mentors can complete 2 years of funded mentor training. Mentors
don't need to be in training or have completed training to be able to
mentor an ECT.

---

Assigned mentor for an ECT can be changed to a different registered
mentor at any time, but cannot be removed.

* 📜 We didn't build this option. Policy that every ECT
must have a mentor

---

User can change mentorship following the same rules above, and:

- ECT must not have completed induction and must not have left the
  school for the SIT to be able to change mentor.

- Mentor must not have left the school for the SIT to be able to
  change the ECT they are assigned to or add others.


## Report ECT is transferring out

Context: Schools can report that an ECT is leaving their school and
transferring to a different school. LPs can view this data via the API
but we otherwise do not use this data.

---

User can report that an ECT is transferring to another school. This
is not mandatory.

* 🙋 This is to allow SITs to tidy their dashboard and move ECTs who
are leaving / have left to a different section ("no longer training")
of their school's dashboard if they want to (see [design history](https://teacher-cpd.design-history.education.gov.uk/manage-training/facilitating-participants-moving-schools-during-their-induction/)).

---

Specify leaving date, which can be in the past or future (no
constraints?).

* 💻 The leaving date triggers the move of that ECT in the SIT
dashboard. Email is sent to the ppt on confirmation?

---

ECT is shown in SIT dashboard as leaving or no longer being trained.

* 💻 Leaving date not shown in the service once it has been submitted, and
can't be changed.

---

ECT cannot be re-added once they have been reported as leaving / have
left.

---

User cannot report through the service if ECT is leaving for any
reason other than transferring to another school.

* 💻 Moving school was the most common option and other journeys were not built
for MVP.

* 🙋 We do not yet have a clear understanding of user needs and pain
points for this journey (see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/teachers-leaving-schools/)).

## Report mentor is transferring out

Context: Schools can report that a mentor is leaving their school and
transferring to a different school. LPs can view this data via the API
but we otherwise do not use this data.

---

User can report that a mentor is transferring to another school. This
is not mandatory.

* 🙋 This is to allow SITs to tidy their dashboard and mark mentors
who are leaving / have left if they want to (see [design
history](https://teacher-cpd.design-history.education.gov.uk/manage-training/facilitating-participants-moving-schools-during-their-induction/)).

---

Specify leaving date, which can be in the past or future (no
constraints?)

* 💻 This date becomes the trigger for removing the mentor from the
school's mentor pool. [Also removes mentorship links?]

---

Leaving date not shown in the service once it has been submitted, and
can't be changed.

<!-- TODO: do we do this or not?
* 💻 Email is sent to the participant on confirmation?

* 🙋 Email is sent to the LP?
-->

---

On the leaving date, mentor is removed from the school's mentor pool.

* 💻 Unless the mentor is working across multiple schools, they are no
longer available to mentor ECTs at the school so are not shown in the
dashboard.

---

Mentor cannot be re-added once they have been reported as leaving /
have left.

---

* 💻 User cannot report through the service if mentor is leaving for any
reason other than transferring to another school.

## Remove an ECT

<!-- TODO: fix this -->
Only if the ECT is 'Exempt' from statutory induction?
Previously a remove journey for unvalidated ppts?

## Contact support or provide feedback on the service

Context: Users may need to access support whilst using the Manage ECTs
service. We also want to encourage them to provide service feedback.

---

User can provide feedback via the feedback form at any point,
including before logging into the service.

* 💻 This follows the [GOV.UK Service Manual for measuring user
satisfaction](https://www.gov.uk/service-manual/measuring-success/measuring-user-satisfaction).

---

User can email continuing-professional-development@digital.education.gov.uk

* 💻 This is to allow users to access support for any issue or query
they may have with the service. contact support.

---

There is no limit on how many times a user can submit feedback or contact support

* 💻 There is no reason to limit feedback or support per user - users
may experience multiple issues that they need support with, and
feedback is anonymous so we have no way of limiting feedback per
user.

---

## View guidance on how to set up and manage ECF training

Context: Schools can find links from the service to gov.uk guidance for
managing ECF training.

---

User can navigate to guidance on [how to set up training for
ECTs](https://www.gov.uk/guidance/how-to-set-up-training-for-early-career-teachers).

* 🙋 This is to provide an overview of what registration involves in
the Manage ECTs service.

---
