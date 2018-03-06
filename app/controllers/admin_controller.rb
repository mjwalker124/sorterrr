# This is the controller to the admin page
class AdminController < ApplicationController
  before_action do
    @current_nav_identifier = :admin
  end

  # Allow students to be imported
  def import
    @current_subnav_identifier = :import
    @student = Student.new
  end

  def delete_data
    @current_subnav_identifier = :delete_data
  end

  # delete data button on /admin/delete-data
  def delete_data_ajax
    Project.destroy_all
    Student.destroy_all
    # TODO: Delete student pictures?
    head :ok
  end
end
