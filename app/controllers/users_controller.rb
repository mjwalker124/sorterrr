class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @current_nav_identifier = :admin
    @current_subnav_identifier = :users
    @users = User.all
    @user = User.new
  end

  # GET /user/1
  def show
    respond_to do |format|
      format.json do
        render json: { user: @user }
      end
    end
  end

  def edit
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update(user_params_password)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def destroy
    return if @user.id == current_user.id

    @user.destroy!
  end

  # PATCH/PUT /user/1
  def update
    render json: { user: @user } if @user.update(user_params)
  end

  def create
    @user = User.new(user_params)

    render json: { user: @user } if @user.save
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :course_year_id)
  end

  def user_params_password
    params.require(:user).permit(:password, :password_confirmation)
  end
end
