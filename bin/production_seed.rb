require_relative '../config/environment'
Rails.application.eager_load!

year1 = CourseYear.where(name: 'Year 1').first_or_create
CourseYear.where(name: 'Year 2').first_or_create
CourseYear.where(name: 'Year 3').first_or_create

User.where(email: 'me1@sheffield.ac.uk').first_or_create(password: 'password', password_confirmation: 'password', course_year: year1)
Course.where(code: 'ARCU103').first_or_create(name: 'BA Architecture')
