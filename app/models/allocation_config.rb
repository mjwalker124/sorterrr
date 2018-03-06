# == Schema Information
#
# Table name: allocation_configs
#
#  id                       :integer          not null, primary key
#  alpha_ability_difference :float
#  alpha_different_tutor    :float
#  hard_iterations_limit    :integer
#  no_improvement_stop      :integer
#  tabu_queue_size          :integer
#

class AllocationConfig < ApplicationRecord
  has_one :user

  # Choosing to set defaults in the model rather than in the database in case we want to allow user to edit default values
  after_initialize :set_defaults, unless: :persisted?

  validates :alpha_ability_difference, :alpha_different_tutor, :hard_iterations_limit, :no_improvement_stop,
            :tabu_queue_size, :user, presence: true

  private

  def set_defaults
    self.alpha_ability_difference ||= 1
    self.alpha_different_tutor ||= 2
    self.hard_iterations_limit ||= 20
    self.no_improvement_stop ||= 10
    self.tabu_queue_size ||= 5
  end
end
