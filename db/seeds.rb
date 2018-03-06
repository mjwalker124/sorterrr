# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



# Destroy some data. delete_all doesn't validate or cascade. This a lot faster than destroy_all
AllocationJob.destroy_all
User.destroy_all
AllocationConfig.destroy_all
Course.destroy_all
CourseYear.destroy_all
Group.destroy_all
HoldingPen.destroy_all
HoldingPenReview.destroy_all
Project.destroy_all
Review.destroy_all
ReviewGroup.destroy_all
Student.destroy_all
Tutor.destroy_all
Review.destroy_all



year1 = CourseYear.where(name: 'Year 1').first_or_create
year2 = CourseYear.where(name: 'Year 2').first_or_create
year3 = CourseYear.where(name: 'Year 3').first_or_create
default_user = User.where(email: 'me@sheffield.ac.uk').first_or_create(password: 'password', password_confirmation: 'password', course_year: year1)
architecture = Course.where(code: 'ARCU103').first_or_create(name: 'BA Architecture')


# http://stackoverflow.com/a/19265735
def choose_weighted(options)
  current, max = 0, options.values.inject(:+)
  random_value = rand(max) + 1
  options.each do |key,val|
    current += val
    return key if random_value <= current
  end
end
def random_ability
  abilities = {'A' => 20, 'B' => 60, 'C' => 10, 'D' => 10}
  choose_weighted abilities
end
def random_email(reg_no)
  "#{reg_no}@sheffield.ac.uk"
end
def random_registration_number
  "150#{Faker::Number.unique.number(6)}"
end

puts 'Creating students'
students = []
overseas_probability = 0.3
students_per_year = 128
students_per_year.times do
  reg_no = random_registration_number
  students << Student.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      registration_number: reg_no,
      email: random_email(reg_no),
      ability: random_ability,
      overseas: Faker::Boolean.boolean(overseas_probability),
      course_year: year1,
      course: architecture
  )
end
students_per_year.times do
  reg_no = random_registration_number
  students << Student.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      registration_number: reg_no,
      email: random_email(reg_no),
      ability: random_ability,
      overseas: Faker::Boolean.boolean(overseas_probability),
      course_year: year2,
      course: architecture
  )
end
students_per_year.times do
  reg_no = random_registration_number
  students << Student.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      registration_number: reg_no,
      email: random_email(reg_no),
      ability: random_ability,
      overseas: Faker::Boolean.boolean(overseas_probability),
      course_year: year3,
      course: architecture
  )
end

Student.import students

puts 'Creating tutors'
tutors = []
tutors_per_year = 8
tutors_per_year.times do
  tutors << Tutor.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      course_year: year1
  )
end
tutors_per_year.times do
  tutors << Tutor.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      course_year: year2
  )
end
tutors_per_year.times do
  tutors << Tutor.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      course_year: year3
  )
end
Tutor.import tutors

puts 'Creating projects'
y1p1 = Project.where(name: 'Y1P1').create(course_year: year1, num_review_periods: 3)
y1p2 = Project.where(name: 'Y1P2').create(course_year: year1, num_review_periods: 1)
y1p3 = Project.where(name: 'Y1P3').create(course_year: year1, num_review_periods: 2)
y1p4 = Project.where(name: 'Y1P4').create(course_year: year1, num_review_periods: 3)
y1p5 = Project.where(name: 'Y1P5').create(course_year: year1, num_review_periods: 1)
y1p6 = Project.where(name: 'Y1P6').create(course_year: year1, num_review_periods: 2)
y1p7 = Project.where(name: 'Y1P7').create(course_year: year1, num_review_periods: 3)
y1p8 = Project.where(name: 'Y1P8').create(course_year: year1, num_review_periods: 1)
y1p9 = Project.where(name: 'Y1P9').create(course_year: year1, num_review_periods: 2)

y2p1 = Project.where(name: 'Y2P1').create(course_year: year2, num_review_periods: 1)
y2p2 = Project.where(name: 'Y2P2').create(course_year: year2, num_review_periods: 3)
y2p3 = Project.where(name: 'Y2P3').create(course_year: year2, num_review_periods: 1)

y3p1 = Project.where(name: 'Y3P1').create(course_year: year3, num_review_periods: 1)
y3p2 = Project.where(name: 'Y3P2').create(course_year: year3, num_review_periods: 1)
y3p3 = Project.where(name: 'Y3P3').create(course_year: year3, num_review_periods: 1)

small_project = Project.create name: 'Small', course_year: year1, num_review_periods: 2
small_project.holding_pen.students = small_project.holding_pen.students.to_a.shuffle[0..15]
small_project.groups = small_project.groups[0..4]

small_project.reviews.each do |review|
  review.holding_pen_review.students = small_project.holding_pen.students
  review.review_groups = review.review_groups[0..4]
end


puts 'Putting some students in groups'
# Add some students to groups of Y1P1
y1p1.groups.each do |g|
  students = y1p1.holding_pen.students.first(16).to_a
  g.students << students
  y1p1.holding_pen.students = y1p1.holding_pen.students.to_a - y1p1.holding_pen.students.to_a.first(16)
end

# Clear the students from the holding pen
y1p1.holding_pen.students.clear
y1p1.reviews.each do |r|
  r.review_groups.each do |g|
    g.students = []
  end
end

tutor = Tutor.where(course_year: year1).first
student = Student.where(course_year: year1).first
