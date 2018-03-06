# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  name               :string
#  course_year_id     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  num_review_periods :integer
#
# Indexesprojects/reviews/18/1
#
#  index_projects_on_course_year_id  (course_year_id)
#

class Project < ApplicationRecord
  belongs_to :course_year
  has_many :groups, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :holding_pen, dependent: :destroy
  has_one :allocation_job, :dependent => :destroy

  validates :name, :course_year, :num_review_periods, presence: true
  validates :num_review_periods, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  after_create :create_initial_associations

  def auto_allocate_student_groups(current_user, allocation_config)
    Delayed::Job.enqueue AutoAllocateJob.new(current_user, self, allocation_config)
  end

  def randomise_student_groups
    # Get all the students associated with the project
    students = []
    groups.each do |group|
      students += group.students.to_a
    end
    students += holding_pen.students.to_a

    # Randomise the order of the students
    random_list = students.shuffle

    num_of_groups = groups.size
    num_of_people_in_group = random_list.length / num_of_groups

    # Delete students from the holding pen
    holding_pen.students.clear

    groups.each do |group|
      group.students.clear
      some_students = random_list.first(num_of_people_in_group).to_a
      group.students << some_students
      random_list = random_list.to_a - random_list.first(num_of_people_in_group).to_a
    end

    # Handle any left-over students
    groups.each do |group|
      single = random_list.first(1).to_a
      group.students << single
      random_list = random_list.to_a - random_list.first(1).to_a
    end
  end

  def greedy_student_allocation
    # Get all the students associated with the project
    students = []
    groups.each do |group|
      students += group.students.to_a
    end
    students += holding_pen.students.to_a

    holding_pen.students.clear
    groups.each do |i|
      i.students.clear
    end

    a_group_i  = []
    a_group_n  = []
    b_group_i  = []
    b_group_n  = []
    c_group_i  = []
    c_group_n  = []
    d_group_i  = []
    d_group_n  = []
    unmarked = []

    students.each do |student|
      if student.ability_int == 1 && student.overseas == 1
        a_group_i << student
      elsif student.ability_int == 1 && student.overseas == 0
        a_group_n << student
      elsif student.ability_int == 2 && student.overseas == 1
        b_group_i << student
      elsif student.ability_int == 2 && student.overseas == 0
        b_group_n << student
      elsif student.ability_int == 3 && student.overseas == 1
        c_group_i << student
      elsif student.ability_int == 3 && student.overseas == 0
        c_group_n << student
      elsif student.ability_int == 4 && student.overseas == 1
        d_group_i << student
      elsif student.ability_int == 4 && student.overseas == 0
        d_group_n << student
      else
        unmarked << student
      end
    end

    groupize(a_group_i)
    groupize(a_group_n)
    groupize(b_group_i)
    groupize(b_group_n)
    groupize(c_group_i)
    groupize(c_group_n)
    groupize(d_group_i)
    groupize(d_group_n)
    groupize(unmarked)
  end

  def self.move_student_to_group(student_id, project_id, old_group_id, new_group_id)
    if new_group_id == 'hp'
      project = Project.find_by(id: project_id)
      new_group = project.holding_pen
    else
      new_group = Group.find_by(id: new_group_id)
    end

    student = Student.find_by(id: student_id)

    if old_group_id == 'hp'
      project = Project.find_by(id: project_id)
      old_group = project.holding_pen
      old_group.students.delete(student)
    else
      old_group = Group.find_by(id: old_group_id)
      student.groups.delete(old_group)
    end

    new_group.students << student
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << [name + ' Project: ' + position_in_year.to_s]

      groups.each do |group|
        csv << [group.tutor.first_name + ' ' + group.tutor.last_name]
        group.students.each do |student|
          csv << ["", student.first_name + ' ' + student.last_name, student.email]
        end
        csv << []
      end
    end
  end

  def position_in_year
    counter = 1
    year = self
    course_year.projects.each do |i|
      return counter if i == year
      counter += 1
    end
  end

  private

  def groupize(ability_group)
    loop do
      groups.each do |group|
        group.students << ability_group.first(1)
        ability_group -= ability_group.first(1)
      end
      break if ability_group.empty?
    end
  end

  protected

  def create_initial_associations
    holding_pen = HoldingPen.create project: self
    holding_pen.students << Student.where(course_year: course_year)

    (1..num_review_periods).each do
      reviews << (Review.create! project: self)
    end

    Tutor.where(course_year: course_year).each do |t|
      Group.create! project: self, tutor: t
    end
  end

  def self.project_groups(project_groups, current_project_id)
    tutors = []
    tutor_ids = []
    project_groups.each do |i|
      tutors.push(i.tutor.first_name + ' ' + i.tutor.last_name)
      tutor_ids.push(i.tutor.id) if i.project.id.to_s == current_project_id
    end
    [tutors.uniq, tutor_ids.uniq]
  end

  def self.project_groups_excluding_current_group(project_groups, current_group_id, project)
    tutors = []
    tutor_ids = []

    number_added = 0
    project_groups.each do |i|
      next unless i.project.position_in_year < project.position_in_year && number_added < 6
      tutors.push(i.tutor.first_name + ' ' + i.tutor.last_name)
      tutor_ids.push(i.tutor.id) if i.id.to_s != current_group_id
      number_added += 1
    end
    [tutors.uniq, tutor_ids.uniq]
  end
end
