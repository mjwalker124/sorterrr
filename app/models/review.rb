# == Schema Information
#
# Table name: reviews
#
#  id         :integer          not null, primary key
#  project_id :integer
#
# Indexes
#
#  index_reviews_on_project_id  (project_id)
#

class Review < ApplicationRecord
  belongs_to :project, touch: true # also bump updated_at timestamp for project when group is touched
  has_many :review_groups, dependent: :destroy
  has_one :holding_pen_review, dependent: :destroy

  validates :project, presence: true
  after_create :create_initial_associations

  def touch_updated_at(_category)
    touch if persisted?
  end

  def randomise_student_groups
    # Get all the students associated with the project
    students = []
    review_groups.each do |group|
      students += group.students.to_a
    end
    students += holding_pen_review.students.to_a

    # Randomise the order of the students
    random_list = students.shuffle

    num_of_groups = review_groups.size
    num_of_people_in_group = random_list.length / num_of_groups

    # Delete students from the holding pen
    holding_pen_review.students.clear

    review_groups.each do |group|
      group.students.clear
      some_students = random_list.first(num_of_people_in_group).to_a
      group.students << some_students
      random_list = random_list.to_a - random_list.first(num_of_people_in_group).to_a
    end

    # Handle any left-over students
    review_groups.each do |group|
      single = random_list.first(1).to_a
      group.students << single
      random_list = random_list.to_a - random_list.first(1).to_a
    end
  end

  def self.move_student_to_review_group(student_id, review_id, old_group_id, new_group_id)
    if new_group_id == 'hp'
      review = Review.find_by(id: review_id)
      new_group = review.holding_pen_review
    else
      new_group = ReviewGroup.find_by(id: new_group_id)
    end

    student = Student.find_by(id: student_id)

    if old_group_id == 'hp'
      review = Review.find_by(id: review_id)
      old_group = review.holding_pen_review
      old_group.students.delete(student)
    else
      old_group = ReviewGroup.find_by(id: old_group_id)
      student.review_groups.delete(old_group)
    end

    new_group.students << student
  end

  def position_in_project
    counter = 1
    review = self
    project.reviews.each do |i|
      return counter if i == review
      counter += 1
    end
    counter
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << [project.name + ' Review: ' + position_in_project.to_s]

      review_groups.each do |group|
        csv << [group.tutor.first_name + ' ' + group.tutor.last_name]
        group.students.each do |student|
          csv << ['', student.first_name + ' ' + student.last_name, student.email]
        end
        csv << []
      end
    end
  end

  def create_initial_associations
    holding_pen_review = HoldingPenReview.create review: self
    holding_pen_review.students << Student.where(course_year: project.course_year)

    Tutor.where(course_year: project.course_year).each do |t|
      ReviewGroup.create! review: self, tutor: t
    end
  end

  def self.non_current_reviewers(review_groups, current_project_id)
    reviewers = []
    reviewer_ids = []
    review_groups.each do |i|
      reviewers.push(i.tutor.first_name + " " + i.tutor.last_name)
      if i.review.project.id.to_s == current_project_id
        reviewer_ids.push(i.tutor.id)
      end
    end
    [reviewers.uniq, reviewer_ids.uniq]
  end

  def self.review_groups_excluding_current_group(review_groups, current_group_id, project, review)
    reviewers = []
    reviewer_ids = []
    number_added = 0

    review_groups.each do |i|
      next unless i.review.project.position_in_year < project.position_in_year ||
                  (i.review.position_in_project < review.position_in_project &&
                  i.review.project.position_in_year == project.position_in_year) &&
                  number_added < 6

      reviewers.push(i.tutor.first_name + " " + i.tutor.last_name)
      reviewer_ids.push(i.tutor.id) if i.id.to_s != current_group_id
      number_added += 1
    end
    [reviewers.uniq, reviewer_ids.uniq]
  end
end
