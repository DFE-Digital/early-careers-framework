# API Reference

This documents the API that serves out post graduate teacher training course,
subject and training provider information. The version of the API documented
here feeds the UCAS Apply system.

# Table of Contents

* [Authorisation](#authorisation)
* [Retrieving Records](#retrieving-records)
  * [Populating an empty system](#populating-an-empty-system)
  * [Retrieving changed records](#retrieving-changed-records)
* [Errors](#errors)
* [Preparation for the next recruitment cycle (rollover)](#preparation-for-the-next-recruitment-cycle-rollover)
  * [Recruitment cycle URL parameter](#recruitment-cycle-url-parameter)
* [Endpoints](#endpoints)
  * [Courses](#courses)
  * [Campuses](#campuses)
  * [Campus statuses](#campus-statuses)
  * [Contacts](#contacts)
  * [Subjects](#subjects)
  * [Providers](#providers)

# Authorisation

The server expects an API key to be included in a header for all API requests,
where `your_api_key` is the api key supplied by the becoming a teacher team:

```
Authorization: Bearer your_api_key
```

## Example

```shell
curl "https://api.publish-teacher-training-courses.service.gov.uk/api/v1/2019/subjects" -H "Authorization: Bearer your_api_key"
```

Replace `your_api_key` with your issued API key.

# Retrieving Records

The "provider" and "course" endpoints support retrieving records changed
since the last request. This is intended to reduce the data transfer volumes
and processing needed to synchronise the UCAS apply system with DfE's course
data on a schedule.

You can control page size using the `?per_page=100` query parameter.

:rocket: _This feature is a work in progress and the API may not yet provide the stated
capabilities and interface_ - [trello
card](https://trello.com/c/HMAlga4l/852-implement-incremental-fetch-for-providers)

The expected usage is as follows:

## Populating an empty system

1. Call the endpoint with no query parameters,
   e.g. `GET https://api.publish-teacher-training-courses.service.gov.uk/api/v1/<recruitment_cycle>/providers`
2. The API will return the first page of records, and will include a response
   header indicating the url needed to request the next page of records.
3. Make another GET using the provided next page url.
4. Repeat until no data is returned. Keep a copy of the next-page url
   provided in the response headers in order to be able to fetch records that
   change after this initial load.

_The above can also be used to refetch all the data periodically to eliminate any drift
that has crept in over time_

## Retrieving changed records

1. Make a GET request using the next-page url provided with the empty
   response at the end of the last full or incremental fetch.
2. The API will return the first page of records, and will include a response
   header indicating the url needed to request the next page of records.
3. Make another GET using the provided next page url.
4. Repeat until no data is returned. Keep a copy of the next-page url
   provided in the response headers in order to be able to fetch records that
   change after this initial load.

Records will be repeated as new changes are recorded so the client **must**
be able to handle duplicate entries in the result sets.

The header will be of the form with the contents of `<...>` replaced with the
correct url:

```
Link: <https://api.publish-teacher-training-courses.service.gov.uk/api/v1/2019/providers?...>; rel="next"
```

**The query parameters are considered an internal concern of the API** and
**must not** be constructed manually in order to avoid losing changes. The
incremental update should only be performed using the next-page urls provided
in the response headers. With that in mind, these are the parameters you
should expect to see:

- `changed_since` - is an ISO 8601 timestamp stating the oldest change to include.


The header format is from [link header
pagination](https://apievangelist.com/2016/05/02/http-header-awareness-using-the-link-header-for-pagination/).

# Errors

The API uses the following error codes:

| Error Code | Meaning                                                                                   |
| ---------- | ----------------------------------------------------------------------------------------- |
| 400        | Bad Request -- Your request is invalid.                                                   |
| 401        | Unauthorized -- Your API key is wrong.                                                    |
| 404        | Not Found -- The specified resource could not be found.                                   |
| 500        | Internal Server Error -- We had a problem with our server. Try again later.               |
| 503        | Service Unavailable -- We're temporarily offline for maintenance. Please try again later. |

# Preparation for the next recruitment cycle (rollover)

During a given recruitment cycle, there will be a period when providers have
two sets of courses to manage – one set of courses that are currently
published for the current recruitment cycle, and unpublished courses being
prepared for the next recruitment cycle. Additionally, the providers who
deliver next year's courses may change, and they may have different campuses
for the same courses. The point in time when the overlap starts is referred
to as rollover, and typically happens in or around May.

To differentiate between entities from different recruitment cycles, each
endpoint has a `<recruitment_cycle>` part in the URL. Additionally, the
following entities have a `recruitment_cycle` attribute in the response data:

- course
- campus
- campus status

## Recruitment cycle URL parameter

`recruitment_cycle` - 4-character year (e.g. 2019 for 2019/20 course)

All the examples in this documentation include `2019` for convenience and
assume you wish to obtain information for the 2019-20 cycle. For future
cycles update the value in the URL, e.g. `2020`.

# Endpoints

## Courses

This endpoint retrieves a paginated list of courses.

- It is segmented by recruitment cycle, see
  [preparation-for-the-next-recruitment-cycle](#Preparation-for-the-next-recruitment-cycle-rollover)
- Results are paginated with a page size of 100 - see [retrieving
  records](#retrieving-records)
- It provides the capability outlined above for [retrieving changed
  records](#retrieving-changed-records).
- Results are sorted oldest update first.

### Example HTTP Requests

First page of the complete data set:

```shell
curl -v "https://api.publish-teacher-training-courses.service.gov.uk/api/v1/2019/courses" -H "Authorization: Bearer your_api_key"
```

Subsequent pages / incremental fetch, using the "next" url in the "Link" header from the previous request:

```shell
curl -v "https://api.publish-teacher-training-courses.service.gov.uk/api/v1/2019/courses?changed_since=xxx" -H "Authorization: Bearer your_api_key"
```

### What constitutes a course change

A course is considered to have been changed (and hence included in this
endpoint) if any of these are true:

- the course itself has been changed
- the campus status has changed
- campus associations have changed
- subject associations have changed

### Entity documentation

| Parameter            | Data type                   | Possible values              | Description                                                         |
| -------------------- | --------------------------- | ---------------------------- | ------------------------------------------------------------------  |
| course_code          | Text                        | 4-character strings          | 4-character course code                                             |
| start_month          | ISO 8601 date/time string   |                              | The month and year when the course starts                           |
| start_month_string   | Text                        | January, February, etc       | The month when the course starts as a string                        |
| name                 | Text                        |                              | Course title                                                        |
| copy_form_required   | Text                        | 'Y' or 'N'                   |                                                                     |
| profpost_flag        | Text                        | "", "PF", "PG", "BO"         | Maximum of 2-characters                                             |
| program_type         | Text                        | "SC", "SS", "TA", "SD", "HE" | Maximum of 2-characters                                             |
| modular              | Text                        | "", "M"                      | Maximum of 1-character                                              |
| english              | Integer                     | 1, 2, 3, 9                   |                                                                     |
| maths                | Integer                     | 1, 2, 3, 9                   |                                                                     |
| science              | Integer                     | 1, 2, 3, 9, null             |                                                                     |
| recruitment_cycle    | Text                        |                              | 4-character year                                                    |
| campus_statuses      | An array of campus statuses |                              | See the campus status entity documentation below                    |
| subjects             | An array of subjects        |                              | See the subject entity documentation below                          |
| provider             | Provider                    | A provider entity            | See the provider entity documentation below (without address data)  |
| accrediting_provider | Provider                    | null or a provider entity    | See the provider entity documentation below (without address data)  |
| age_range            | Text                        | "P", "S", "M", "O"           | Age of students targeted by this course.                            |
| created_at           | ISO 8601 date string        | "2019-07-18T12:00:00Z"       | A timestamp of when this provider was first added to the database. |
| changed_at           | ISO 8601 date string        | "2019-07-18T14:14:07Z"       | A timestamp of when this provider was last changed in the database. |

### Course codes

- are unique within a provider
- are not unique across providers
- are stable across rollover (i.e. by default, a course in a particular subject
  delivered by the same provider will have the same course code across
  different recruitment cycles)

### Example response body

```json
[
  {
    "course_code": "36B3",
    "start_month": "2019-09-01T00:00:00.000Z",
    "start_month_string": "September",
    "name": "Mathematics",
    "study_mode": "F",
    "copy_form_required": "Y",
    "profpost_flag": "PG",
    "program_type": "SD",
    "modular": "M",
    "english": 1,
    "maths": 3,
    "science": null,
    "qualification": 1,
    "recruitment_cycle": "2019",
    "age_range": "S",
    "created_at": "2019-07-18T12:00:00Z",
    "changed_at": "2019-07-18T14:14:07Z",
    "campus_statuses": [
      {
        "campus_code": "-",
        "name": "Main Site",
        "vac_status": "F",
        "publish": "Y",
        "status": "R",
        "course_open_date": "2018-10-09",
      }
    ],
    "subjects": [
      {
        "subject_name": "Secondary",
        "subject_code": "05"
      },
      {
        "subject_name": "Mathematics",
        "subject_code": "G1"
      }
    ],
    "provider": {
      "institution_code": "2G9",
      "institution_name": "Outwood Institute of Education North",
      "institution_type": "Y",
      "accrediting_provider": "Y",
    },
    "accrediting_provider": {
      "institution_code": "D86",
      "institution_name": "Durham University",
      "institution_type": "Y",
      "accrediting_provider": "Y"
    }
  },
  {
    ...
  }
]
```

## Campuses

### Entity documentation

| Parameter         | Data type | Possible values     | Description              |
| ----------------- | --------- | ------------------- | ------------------------ |
| campus_code       | Text      | A-Z, 0-9, "-" or "" | 1-character campus codes |
| name              | Text      |                     |
| region_code       | Text      | 01 to 11            | 2-character string       |

:warning: - _A single provider can have at most 37 campuses._

## Campus statuses

### Entity documentation

| Parameter         | Data type            | Possible values   | Description              |
| ----------------- | -------------------- | ----------------- | ------------------------ |
| campus_code       | Text                 | A-Z, 0-9, "-", "" | 1-character campus codes |
| name              | Text                 |                   |
| vac_status        | Text                 |                   |
| publish           | Text                 |                   |
| status            | Text                 |                   |
| course_open_date  | ISO 8601 date string |                   |

## Contacts

### Entity documentation

| Parameter         | Data type | Possible values     | Description                                                       |
| ----------------- | --------- | ------------------- | ----------------------------------------------------------------- |
| contact_type      | Text      | A-Z, 0-9, "-" or "" | Type of contact, one of a pre-defined list. See below for details |
| name              | Text      |                     | Name of contact.                                                  |
| email             | Text      |                     | Email address for the contact.                                    |
| telephone         | Text      |                     | Telephone for the contact.                                        |

### Contact Types

UCAS defines a number of contact types (called "contact groups"). Only the
subset of contact groups required by the DfE course publishing system is used for the contact types here. This list is:

| Contact Type                | UCAS "contact group"   | Contact Purpose                                                                                                                  |
| --------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| admin                       | n/a                    | This is the lead UCAS contact.                                                                                                   |
| utt                         | UTT Correspondent      | This person will receive the UCAS monthly bulletin, which will include information about deadlines for making decisions.         |
| web_link                    | web-link Correspondent | This person will receive notices about UCAS systems and planned downtime.                                                        |
| fraud                       | Fraud Correspondent    | This person will receive alerts about fradulent activity, for example similarity detection for a plagiarised personal statement. |
| finance                     | UTT finance contact    | This person will receive invoices from UCAS for payment of fees.                                                                 |
| application_alert_recipient | UTT Output             | This person will receive alerts about new applications.                                                                          |

### Example

See the example in the [Providers](#providers) section.

## Subjects

This endpoint retrieves all subjects.

- It is not paginated.
- It is segmented by recruitment cycle, see
  [preparation-for-the-next-recruitment-cycle](#Preparation-for-the-next-recruitment-cycle-rollover)

### Example HTTP Request

```shell
curl "https://api.publish-teacher-training-courses.service.gov.uk/api/v1/2019/subjects" -H "Authorization: Bearer your_api_key"
```

### List of known subjects

| Subject Code | Subject Name                         |
|--            |--                                    |
| 00           | Primary                              |
| 01           | Primary with English                 |
| 02           | Primary with geography and history   |
| 03           | Primary with mathematics             |
| 04           | Primary with modern languages        |
| 06           | Primary with physical education      |
| 07           | Primary with science                 |
| W1           | Art and design                       |
| F0           | Science                              |
| C1           | Biology                              |
| 08           | Business studies                     |
| F1           | Chemistry                            |
| 09           | Citizenship                          |
| Q8           | Classics                             |
| P3           | Communication and media studies      |
| 11           | Computing                            |
| 12           | Dance                                |
| DT           | Design and technology                |
| 13           | Drama                                |
| L1           | Economics                            |
| Q3           | English                              |
| F8           | Geography                            |
| L5           | Health and social care               |
| V1           | History                              |
| G1           | Mathematics                          |
| W3           | Music                                |
| P1           | Philosophy                           |
| C6           | Physical education                   |
| F3           | Physics                              |
| C8           | Psychology                           |
| V6           | Religious education                  |
| 14           | Social sciences                      |
| 15           | French                               |
| 16           | English as a second or other language|
| 17           | German                               |
| 18           | Italian                              |
| 19           | Japanese                             |
| 20           | Mandarin                             |
| 21           | Russian                              |
| 22           | Spanish                              |
| 24           | Modern languages (other)             |
| 41           | Further education                    |
| U3           | Special Educational Needs            |


### Entity documentation

| Parameter    | Data type | Possible values     | Description               |
| ------------ | --------- | ------------------- | ------------------------- |
| subject_code | Text      | 2-character strings | 2-character subject codes |
| subject_name | Text      |                     |

### Example response body

```json
[
  {
    "subject_name": "Chinese",
    "subject_code": "T1"
  },
  {
    ...
  }
]
```

## Providers

This endpoint retrieves all institutions.

- It is segmented by recruitment cycle, see
  [preparation-for-the-next-recruitment-cycle](#Preparation-for-the-next-recruitment-cycle-rollover)
- Results are paginated with a page size of 100 - see [retrieving
  records](#retrieving-records)
- It provides the capability outlined above for [retrieving changed
  records](#retrieving-changed-records).
- Results are sorted oldest update first.
### Example HTTP Request

```shell
curl "https://api.publish-teacher-training-courses.service.gov.uk/api/v1/2019/providers" -H "Authorization: Bearer your_api_key"
```

### What constitutes a provider change

A provider is considered to have been changed (and hence included in this
endpoint) if any of these are true:

- the provider itself has been changed (including contact data changes)
- any of the associated campuses has changed
- campus associations have changed

### Entity documentation

| Parameter              | Data type            | Possible values                                                                                            | Description                                                                                          |
| ---------------------- | ------------------   | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| institution_code       | Text                 | 3-character strings                                                                                        | 3-character UCAS institution code                                                                    |
| institution_name       | Text                 |                                                                                                            | The institution's full-length marketing name                                                         |
| institution_type       | Text                 | "Y", "B", "0", "O", null                                                                                   | The type of institution (whether it's a university, lead school/teaching school alliance or a SCITT) |
| accrediting_provider   | Text                 | "Y" or "N"                                                                                                 | Whether the provider can accredit courses or not                                                     |
| campuses               | An array of campus   |                                                                                                            | See the campus entity documentation above                                                            |
| contacts               | Array of contacts    |                                                                                                            | List of contact objects that include group                                                           |
| address1               | Text                 |                                                                                                            | Address line 1                                                                                       |
| address2               | Text                 |                                                                                                            | Address line 2                                                                                       |
| address3               | Text                 |                                                                                                            | Town/City                                                                                            |
| address4               | Text                 |                                                                                                            | County                                                                                               |
| postcode               | Text                 |                                                                                                            | Postcode                                                                                             |
| region_code            | Text                 | 01 to 11                                                                                                   | 2-character string                                                                                   |
| utt_application_alerts | Text                 | `No, not required`, `Yes, required`, `Yes - only my programmes` or `Yes - for accredited programmes only`  | New UTT Application alerts                                                                           |
| type_of_gt12           | Text                 | `Coming / Enrol`, `Coming or Not`, `No response` or `Not coming`                                           |                                                                                                      |
| scheme_member          | Text                 | `Y` or `N`                                                                                                 |                                                                                                      |
| recruitment_cycle      | Text                 |                                                                                                            | 4-character year                                                                                     |
| gt12_contact_address   | Text                 |                                                                                                            | Email or URL for the candidate to contact that will be inserted into the GT12 letter sent them.      |
| created_at             | ISO 8601 date string | "2019-07-18T12:00:00Z"                                                                                     | A timestamp of when this provider was first added to the database.             |
| changed_at             | ISO 8601 date string | "2019-07-18T14:14:07Z"                                                                                     | A timestamp of when this provider was last changed in the database.                                  |


### Example response body

```json
[
  {
    "institution_code": "P60",
    "institution_name": "University of Plymouth",
    "institution_type": "Y",
    "accrediting_provider": "Y",
    "address1": "Sydney Russell School",
    "address2": "Parsloes Avenue",
    "address3": "Dagenham",
    "address4": "Essex",
    "postcode": "RM9 5QT",
    "telephone": "020 812 345 678",
    "email": "info@acmescitt.education.uk",
    "contact_name": "Amy Smith",
    "region_code": "01",
    "scheme_member": "Y",
    "recruitment_cycle": "2019",
    "gt12_contact_address": "info@asmescitt.education.uk",
    "created_at": "2019-07-18T12:00:00Z",
    "changed_at": "2019-07-18T14:14:07Z",
    "campuses": [
      {
        "campus_code": "",
        "name": "Main Site",
        "region_code": "01"
      }
    ],
    "contacts": [
      {
        "type": "admin_contact",
        "name": "Andy Admin",
        "email": "admin@asmescitt.education.uk",
        "telephone": "020 7946 0936"
      },
      {
        "type": "utt_correspondent",
        "name": "UTT Corey",
        "email": "utt.corey@asmescitt.education.uk",
        "telephone": "020 7946 0935"
      },
      {
        "type": "web_link_correspondent",
        "name": "Web Link",
        "email": "web_link@asmescitt.education.uk",
        "telephone": "020 7946 0733"
      },
      {
        "type": "fraud_contact",
        "name": "Fraught Fred",
        "email": "fraud@asmescitt.education.uk",
        "telephone": "020 7946 0043"
      },
      {
        "type": "finance_contact",
        "name": "Finance Finn",
        "email": "finance@asmescitt.education.uk",
        "telephone": "020 7946 0722"
      },
      {
        "type": "application_alert_recipient",
        "name": "Amy Alert",
        "email": "alert@asmescitt.education.uk",
        "telephone": "020 7946 0145"
      }
    ]
  },
  {
    ...
  }
]
```
