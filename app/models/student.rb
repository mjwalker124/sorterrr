# == Schema Information
#
# Table name: students
#
#  id                  :integer          not null, primary key
#  first_name          :string
#  last_name           :string
#  registration_number :integer
#  email               :string
#  ability             :integer
#  overseas            :boolean
#  course_year_id      :integer
#  course_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_students_on_course_id       (course_id)
#  index_students_on_course_year_id  (course_year_id)
#

class Student < ApplicationRecord
  require 'csv'
  require 'fileutils'
  require 'zip'

  belongs_to :course_year
  belongs_to :course
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :review_groups

  validates :first_name, :last_name, :registration_number, :email, :ability, :course_year, :course, presence: true
  validates_inclusion_of :overseas, in: [true, false]

  def image_url
    expected = "uploads/images/students/#{registration_number}.png"
    if File.file?(expected)
      "/students/#{id}.png"
    else
      '/images/unknown.jpg'
    end
  end

  def ability
    convert_ability self[:ability]
  end

  def ability_int
    convert_ability ability
  end

  def ability=(ability)
    write_attribute :ability, convert_ability(ability)
  end

  def convert_ability(ability)
    hash = if ability.is_a? String
             Hash[('A'..'Z').to_a.zip((1..27).to_a)]
           else
             Hash[(1..26).to_a.zip(('A'..'Z').to_a)]
           end
    hash[ability]
  end

  def set_ability(ability)
    ability = convert_ability(ability.to_i)
    self.ability = ability.to_i
  end

  def self.import_from_file(file_path, course_year)
    CSV.foreach(file_path, headers: true) do |row|
      h = row.to_hash
      h['course_year'] = course_year
      h['course'] = Course.find_by_code h['course_code']
      h.except! 'course_code'
      h['ability'] = 'D' if h['ability'].nil? || h['ability'].strip == ''
      Student.create!(h)
    end
  end

  def self.import_pictures_from_file(file)
    directory_path = 'uploads/images/students'
    FileUtils.mkdir_p directory_path unless File.exist? directory_path

    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        if File.exist? directory_path + '/' + f.name
          FileUtils.rm directory_path + '/' + f.name
        end
        f.extract directory_path + '/' + f.name
      end
    end
  end
end
