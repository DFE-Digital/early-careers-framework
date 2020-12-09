# frozen_string_literal: true

class SupplierDashboardController < ApplicationController
  def show
    @content = Govspeak::Document.new(
      '

Welcome to Ambition Institute’s Early Career Teachers programme. This programme has been designed to help teachers early in their career to keep getting better in the most accessible way possible.

<!-- wp:block {"ref":1541} /-->

## Early Career Teachers

This programme has been designed to bring about lasting change in teachers’ understanding and practice. The programme takes a recurring weekly approach to study and coaching, so teachers and the mentors supporting them can get into powerful routines for improvement. Each week includes:

<!-- wp:list -->

- Concise, accessible summaries of the evidence, with optional further reading, so teachers can gain understanding quickly.
- Short videos of experts talking through the most important insights, and showing what they look like in practice.
- Mentor sessions that link closely with the summaries and videos, and provide support so they can conduct effective instructional coaching.

<!-- /wp:list -->

We are deeply passionate about helping teachers to keep getting better, using the best and latest evidence of what works.

{button}[Go to self-directed study materials](https://www.early-career-framework.education.gov.uk/ambition/ambition-institute/self-directed-study-materials/){/button}

{button}[Download all teacher materials](https://www.early-career-framework.education.gov.uk/ambition/wp-content/uploads/sites/3/2020/09/EarlyCareerTeachers_TextbookDigital_Teachers_v3-compressed.pdf){/button}

## Mentors

Your role as a mentor encompasses everything you do to support your NQT. Instructional coaching is a central and critical aspect of this role – one that can make a big difference to your teacher’s practice.

For more information on mentoring and instructional coaching, see the [ECF Mentor Handbook (PDF)](http://www.early-career-framework.education.gov.uk/ambition/wp-content/uploads/sites/3/2020/08/Ambition-EarlyCareerTeachers_2020_MentorHandbook_Guidebook_FULL_DEV.pdf).

If you have further questions about the programme, contact your ECF Lead.

{button}[Download all mentor materials](https://github.com/DFE-Digital/early-career-framework/raw/master/EarlyCareerTeachers_TextbookDigital_Mentors_v2-compressed.pdf){/button}

<!-- wp:acf/accordion {
    "id": "block_5f47ba53c570f",
    "name": "acf\/accordion",
    "data": {
        "section_0_heading": "Mentor materials – Behaviour",
        "_section_0_heading": "field_5f157322f8e8c",
        "section_0_summary": "Download mentor materials for the Behaviour strand",
        "_section_0_summary": "field_5f157342f8e8d",
        "section_0_content": "<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B01-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B1.pdf\">B1: Strand overview and contracting (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B02-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B2.pdf\">B2: Routines (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B03-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B3.pdf\">B3: Instructions (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B04-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B4.pdf\">B4: Directing attention (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/ambition-p3-b05-earlycareerteachers_2020_mentorhandbooks_julyupdate_b5\/\">B5: Low-level disruption (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B06-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B6.pdf\">B6: Consistency (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B07-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B7.pdf\">B7: Positive learning environment (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B08-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B8.pdf\">B8: Structured support of learning (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B09-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B9.pdf\">B9: Challenge (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B10-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B10.pdf\">B10: Independent practice (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B11-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B11.pdf\">B11: Pairs and groups (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-B12-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_B12.pdf\">B12: Upholding high expectations (PDF)<\/a>",
        "_section_0_content": "field_5f157359f8e8e",
        "section_1_heading": "Mentor materials – Instruction",
        "_section_1_heading": "field_5f157322f8e8c",
        "section_1_summary": "Download mentor materials for the Instruction strand",
        "_section_1_summary": "field_5f157342f8e8d",
        "section_1_content": "<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I01-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I1.pdf\">I1: Strand overview and (re)contracting (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I02-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I2.pdf\">I2: Identifying the learning content (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I03-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I3.pdf\">I3: Instruction for memory (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I04-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I4.pdf\">I4: Prior knowledge (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I05-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I5.pdf\">I5: Teacher exposition (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I06-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I6.pdf\">I6: Adapting teaching (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I07-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I7.pdf\">I7: Practice and success (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I08-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I8.pdf\">I8: Explicit teaching (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I09-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I9.pdf\">I9: Scaffolding (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I10-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I10.pdf\">I10: Questioning (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I11-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I11.pdf\">I11: Classroom talk (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-I12-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_I12.pdf\">I12: Feedback (PDF)<\/a>",
        "_section_1_content": "field_5f157359f8e8e",
        "section_2_heading": "Mentor materials – Subject",
        "_section_2_heading": "field_5f157322f8e8c",
        "section_2_summary": "Download mentor materials for the Subject strand",
        "_section_2_summary": "field_5f157342f8e8d",
        "section_2_content": "<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S01-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S1.pdf\">S1: Strand overview and (re)contracting (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S02-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S2.pdf\">S2: Planning backwards from learning goals (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S03-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S3.pdf\">S3: Types of knowledge (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S04-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S4.pdf\">S4: Gaps and misconceptions (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S05-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S5.pdf\">S5: Acquisition before application (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S06-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S6.pdf\">S6: Promoting deep thinking (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S07-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S7.pdf\">S7: Developing pupils\' literacy (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S08-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S8.pdf\">S8: Sharing academic expectations (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P3-S09-EarlyCareerTeachers_2020_MentorHandbooks_JulyUpdate_S9.pdf\">S9: Assessing for formative purposes (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/09\/ECF_MENTOR-HANDBOOK_S10-EEF-CommentsSM-proof.pdf\">S10: Examining pupils responses (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/09\/ECF_MENTOR-HANDBOOK_S11-EEF-CommentsSM-proof.pdf\">S11: Adapting lessons to meet pupil needs (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/09\/ECF_MENTOR-HANDBOOK_S12-EEF-CommentsSM-proof.pdf\">S12: Feedback (PDF)<\/a>",
        "_section_2_content": "field_5f157359f8e8e",
        "section": 3,
        "_section": "field_5f157313f8e8b"
    },
    "mode": "auto"
} /-->

## ECF Leads

Your role as an ECF Lead requires you to have a good understanding of the framework, the entitlement it sets out for teachers and mentors, and the support mentors and teachers will need. Schools are busy, demanding places – careful planning and ongoing attention to implementation will be critical to ensure that the ECF is a success.

The ECF Lead Handbook provides an overview of your role and responsibilities as an ECF lead, along with guidance for how to ensure an effective and smooth implementation of the Early Career Framework for your school. Before reading this document, it is important that you have first read the Programme Handbook, as this will ensure you understand the core features of the programme and how it works.

{button}[Download all ECF Lead materials](<https://github.com/DFE-Digital/early-career-framework/raw/master/EarlyCareerTeachers_TextbookDigital_In-SchoolLead_v3%20(1)-compressed.pdf>){/button}

{button}[Download ECF Programme Handbook (PDF)](http://www.early-career-framework.education.gov.uk/ambition/wp-content/uploads/sites/3/2020/08/Ambition-EarlyCareerTeachers_2020_ProgrammeHandbook.pdf){/button}

{button}[Download ECF Lead Handbook (PDF)](https://www.early-career-framework.education.gov.uk/ambition/wp-content/uploads/sites/3/2020/09/Ambition-EarlyCareerTeachers_2020_LeadHandbook_Guidebook_Edit-1-1.pdf){/button}

## Training materials

When the Early Career Framework reforms are launched nationally in 2021, the Full Induction Programmes will include face-to-face training. Schools who choose to use the Core Induction Programme will design and deliver the early career teacher and mentor training themselves. For those schools, we are including training outlines with this release which give guidance on what should be covered in the early career teacher training.

<!-- wp:acf/accordion {
      "id": "block_5f47d112f0409",
          "name": "acf\/accordion",
          "data": {
          "section_0_heading": "ECF training materials for NQTs",
          "_section_0_heading": "field_5f157322f8e8c",
          "section_0_summary": "Download materials for NQT training programme",
          "_section_0_summary": "field_5f157342f8e8d",
          "section_0_content": "<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-Conf-1-EarlyCareerTeachers_2020_ClinicTimetables_Conference1_Dev1_AK.pdf\">Kick-off conference (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-Induction-EarlyCareerTeachers_2020_ClinicTimetables_ProgrammeOrientation_Dev1_AK.pdf\">Programme induction (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C01-EarlyCareerTeachers_2020_ClinicTimetables_Clinic1_Dev1_AK.pdf\">Clinic 1: Supporting all pupils (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C02-EarlyCareerTeachers_2020_ClinicTimetables_Clinic2_Dev1_AK.pdf\">Clinic 2: Responding to challenging behaviour (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C03-EarlyCareerTeachers_2020_ClinicTimetables_Clinic3_Dev1_AK.pdf\">Clinic 3: Building effective relationships with parents and carers _PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C04-EarlyCareerTeachers_2020_ClinicTimetables_Clinic4_Dev1_AK.pdf\">Clinic 4: Adapting teaching for pupils (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C05-EarlyCareerTeachers_2020_ClinicTimetables_Clinic5_Dev1_AK.pdf\">Clinic 5: Teacher wellbeing and workload (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C06-EarlyCareerTeachers_2020_ClinicTimetables_Clinic6_Dev1_AK.pdf\">Clinic 6: Early literacy 1 – Reading and phonics (PDF) <\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-Conf-2-EarlyCareerTeachers_2020_ClinicTimetables_Conference2_Dev1_AK.pdf\">Conference 2: Wellbeing and Implementing change (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C07-EarlyCareerTeachers_2020_ClinicTimetables_Clinic7_Dev1_AK.pdf\">Clinic 7: Pupil wellbeing (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C08-EarlyCareerTeachers_2020_ClinicTimetables_Clinic8_Dev1_AK.pdf\">Clinic 8: Implementing change: Prepare (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C09-EarlyCareerTeachers_2020_ClinicTimetables_Clinic9_Dev1_AK.pdf\">Clinic 9: Support and interventions (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C10-EarlyCareerTeachers_2020_ClinicTimetables_Clinic10_Dev1_AK.pdf\">Clinic 10: Implementing change: Deliver (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C11-EarlyCareerTeachers_2020_ClinicTimetables_Clinic11_Dev1_AK.pdf\">Clinic 11: Early literacy 2 (PDF)<\/a>\r\n\r\n<a href=\"https:\/\/www.early-career-framework.education.gov.uk\/ambition\/wp-content\/uploads\/sites\/3\/2020\/08\/Ambition-P4-C12-EarlyCareerTeachers_2020_ClinicTimetables_Clinic12_Dev1_AK.pdf\">Clinic 12: Implementing change: Sustain (PDF)<\/a>",
          "_section_0_content": "field_5f157359f8e8e",
          "section": 1,
          "_section": "field_5f157313f8e8b"
      },
          "mode": "auto"
    } /-->

{button}[Continue](https://gov.uk/random){/button}

{button start}[Start Now](https://gov.uk/random){/button}



',
    ).to_html
  end
end
