class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy, :reset_groups, :randomize]

  # POST /reviews
  def create
    @review = Review.new(review_params)

    return unless @review.save
    render json: { review_id: @review.id, position_in_project: @review.position_in_project }, status: 200
  end

  # POST /reviews/delete/1
  def delete
    @review = Review.find(params[:id])
    @review.destroy
  end

  def reset_groups
    @review.review_groups.each do |group|
      @review.holding_pen_review.students += group.students
      group.students.clear
    end
    head :ok
  end

  def randomize
    @review.randomise_student_groups
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_review
    @review = Review.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def review_params
    params.permit(:review, :tutor_id, :student_id, :project_id)
  end
end
