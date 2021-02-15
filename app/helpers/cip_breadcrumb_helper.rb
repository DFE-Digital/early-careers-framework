# frozen_string_literal: true

module CipBreadcrumbHelper
  def course_year_breadcrumbs(user)
    [home_crumb(user)]
  end

  def course_module_breadcrumbs(user, course_module)
    [
      home_crumb(user),
      course_module_crumb(course_module),
    ]
  end

  def course_lesson_breadcrumbs(user, course_lesson)
    [
      home_crumb(user),
      course_module_crumb(course_lesson.course_module),
      course_lesson_crumb(course_lesson),
    ]
  end

private

  def home_crumb(user)
    ["Home", user ? dashboard_path : cip_path]
  end

  def course_module_crumb(course_module)
    [course_module.course_year.title, cip_year_path(course_module.course_year)]
  end

  def course_lesson_crumb(course_lesson)
    [course_lesson.course_module.title, cip_year_module_path(course_lesson.course_module.course_year, course_lesson.course_module)]
  end
end
