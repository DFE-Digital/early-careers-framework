# frozen_string_literal: true

module CipBreadcrumbHelper
  def home_breadcrumbs(user)
    [home_crumb(user)]
  end

  def course_year_breadcrumbs(user, course_year)
    year_crumb = course_year_crumb(course_year)
    [
      home_crumb(user),
      end_crumb(year_crumb),
    ]
  end

  def course_module_breadcrumbs(user, course_module)
    module_crumb = course_module_crumb(course_module)
    [
      home_crumb(user),
      course_year_crumb(course_module.course_year),
      end_crumb(module_crumb),
    ]
  end

  def course_lesson_breadcrumbs(user, course_lesson)
    lesson_crumb = course_lesson_crumb(course_lesson)
    [
      home_crumb(user),
      course_year_crumb(course_lesson.course_module.course_year),
      course_module_crumb(course_lesson.course_module),
      end_crumb(lesson_crumb),
    ]
  end

private

  def home_crumb(user)
    ["Home", user ? dashboard_path : cip_path]
  end

  def course_year_crumb(course_year)
    [course_year.title, year_path(course_year)]
  end

  def course_module_crumb(course_module)
    [course_module.title, year_module_path(course_module.course_year, course_module)]
  end

  def course_lesson_crumb(course_lesson)
    [course_lesson.title, year_module_lesson_path(course_lesson.course_module.course_year, course_lesson.course_module, course_lesson)]
  end

  def end_crumb(crumb)
    action_name == "show" ? crumb[0] : crumb
  end
end
