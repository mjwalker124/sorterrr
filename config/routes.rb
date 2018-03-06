Rails.application.routes.draw do
  get '/admin/students', to: 'students#index', as: :students
  get '/admin/courses', to: 'courses#index', as: :courses
  get '/admin/course_years', to: 'course_years#index', as: :course_years
  get '/admin/tutors', to: 'tutors#index', as: :tutors
  get '/admin/users', to: 'users#index', as: :users
  patch '/admin/students', to: 'students#update'
  post '/admin/students', to: 'students#create', as: :students_create
  post '/admin/tutors', to: 'tutors#create', as: :tutors_create
  patch '/admin/tutors', to: 'tutors#update'
  patch '/admin/course_years', to: 'course_years#update'
  post '/admin/course_years', to: 'course_years#create', as: :course_years_create
  post '/admin/courses', to: 'courses#create', as: :courses_create
  patch '/admin/courses', to: 'courses#update'
  post '/admin/users', to: 'users#create', as: :users_create
  patch '/admin/users', to: 'users#update'
  resources :holding_pens
  resources :reviews
  resources :projects
  resources :groups
  resources :allocation_job
  resources :students, except: :index do
    collection { post :import }
  end

  post '/students/import/pictures', to: 'students#import_pictures', as: :import_student_pictures

  resources :courses, except: :index
  resources :tutors, except: :index
  resources :course_years

  devise_for :users, skip: [:registrations]
  resources :users, only: [:show, :update, :new, :create, :destroy, :edit] do
    collection do
      patch 'update_password'
    end
  end


  match "/403", to: "errors#error_403", via: :all
  match "/404", to: "errors#error_404", via: :all
  match "/422", to: "errors#error_422", via: :all
  match "/500", to: "errors#error_500", via: :all

  get :ie_warning, to: 'errors#ie_warning'
  get :javascript_warning, to: 'errors#javascript_warning'

  get '/admin/user', to: 'user#index', as: :user_index
  get '/admin', to: 'students#index'
  get '/admin/import', to: 'admin#import', as: :admin_import
  get '/admin/delete-data', to: 'admin#delete_data', as: :admin_delete_data
  post '/admin/delete-data', to: 'admin#delete_data_ajax'

  get '/projects/reviews/:id(/:review_id)', to: 'projects#reviews', as: :project_review
  post '/reviews/delete/:id', to: 'reviews#delete'
  post '/reviews/:id/reset_groups', to: 'reviews#reset_groups'
  post '/reviews/:id/randomize', to: 'reviews#randomize'
  post '/projects/student_review_group', to: 'projects#student_review_group'
  post '/projects/student_group', to: 'projects#student_group'
  get '/projects/:id/print', to: 'projects#print', as: :project_print
  post '/students/:id/set_ability', to: 'students#set_ability'
  post '/projects/:id/auto_allocate', to: 'projects#auto_allocate'
  post '/projects/:id/reset_groups', to: 'projects#reset_groups'

  post '/projects/randomize/:id', to: 'projects#randomize'
  post '/projects/good_fit/:id', to: 'projects#good_fit'

  get '/allocation_jobs/get_queue_size', to: 'allocation_jobs#queue_size'
  get '/allocation_job/project_info/:project_id', to: 'allocation_jobs#project_info'
  root to: 'dashboard#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
