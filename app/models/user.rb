# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  allocation_config_id   :integer
#  course_year_id         :integer
#
# Indexes
#
#  index_users_on_allocation_config_id  (allocation_config_id)
#  index_users_on_course_year_id        (course_year_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :allocation_config, dependent: :destroy
  has_many :allocation_jobs

  belongs_to :course_year
  validates :course_year, presence: true
  validates :email, presence: true
  after_create :create_initial_associations

  private

  def create_initial_associations
    self.allocation_config = AllocationConfig.create
    save
  end
end
