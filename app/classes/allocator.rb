# This is the allocator class which handles optimising the allocation of students to project groups and review groups
class Allocator
  min_ability_value = 1
  max_ability_value = 4

  MAX_ABILITY_DIFFERENCE = (max_ability_value - min_ability_value)

  def initialize(project, allocation_config)
    @project = project

    # Alphas (criteria weights)
    @alpha_ability_difference = allocation_config.alpha_ability_difference
    @alpha_different_tutor = allocation_config.alpha_different_tutor

    # General algorithm runtime options
    @hard_iterations_limit = allocation_config.hard_iterations_limit
    @no_improvement_stop = allocation_config.no_improvement_stop
    @tabu_queue_size = allocation_config.tabu_queue_size
  end

  # Tabu search implementation inspired by paper at http://ieeexplore.ieee.org/document/5518761/?reload=true
  def allocate
    start_time = Time.now

    ActiveRecord::Base.transaction do
      # Allocate students to project groups using tabu search optimisation approach
      project_groups, k = allocate_project_groups

      # Allocate students to review groups in a greedy way (may integrate into tabu search if time)
      greedy_allocate_reviews project_groups, k
    end

    time_taken = Time.now - start_time
    puts "Time taken to complete: #{time_taken} seconds."
  end

  def allocate_project_groups
    # Create arrays of objects instead of using group objects to improve memory efficiency in algorithm
    # Note that currently the groups array and tutors array should correspond index-wise!
    students = []
    tutors = []
    @project.groups.each do |group|
      students += group.students.to_a
      tutors << group.tutor
    end
    students += @project.holding_pen.students.to_a
    num_groups = @project.groups.count

    throw 'Num students must be > 1' if students.length <= 1
    throw 'Number of groups must equal number of tutors' if num_groups != tutors.length

    k = make_k_vector students.length, num_groups

    m = k.length # m is the number of groups

    # Initialise a hash for storing last time a student was swapped - keyed by student id
    t_students = {}

    # 1) Initialise
    # puts '1'

    # let G_1,...,G_m be a random partition of students such that |G_i| = k_i f.a. i, 1<=i<=m
    groups = random_partition(students, k)

    # initialise current state S, best state S* (s_best), current time tc, and time tc* when best state was found
    s = groups
    s_best = s
    tc = tc_best = 0

    # 2) Generate
    # puts '2'

    while tc - tc_best <= @no_improvement_stop && tc < @hard_iterations_limit
      # puts "tc: #{tc}"
      moves = []

      # initialise the set of neighbour states
      v = []
      # find all potential neighbour states
      (1..m).each do |i|
        (1..m).each do |j|
          next if i == j

          # puts "2.1 #{i}, #{j}"

          g_i = s[i - 1]
          g_j = s[j - 1]

          g_i.each_with_index do |x, x_i|
            g_j.each_with_index do |y, y_i|
              # f.a. possible moves M
              # puts "2.2 #{x_i}, #{y_i}"
              g_i_copy = g_i.clone
              g_j_copy = g_j.clone

              # swap x and y between g_i and g_j
              g_i_copy[x_i], g_j_copy[y_i] = g_j_copy[y_i], g_i_copy[x_i]
              groups_except_i_and_j = s.reject.with_index { |_, idx| idx == i - 1 || idx == j - 1 }

              # Compute M(S) i.e. the state S with move M applied to it
              m_s = [g_i_copy, g_j_copy] + groups_except_i_and_j # possible move
              move = [x, y] # encode a move as a list of x and y

              t_x = t_students[x.id] || 0
              t_y = t_students[y.id] || 0

              tabu = tc - t_x < @tabu_queue_size || tc - t_y < @tabu_queue_size

              # asp corresponds to chosen aspiration
              asp = f(m_s, tutors) > f(s_best, tutors)
              next unless !tabu || asp
              # add state M(S) to neighbour set V
              # if M is not tabu or the aspiration criterion applies
              v << m_s
              moves << move
              # store the move that generated m_s for later (will have same index between v and moves)
            end
          end
        end
      end

      # 3) Select
      # puts '3'

      # throw 'V (neighbours) is empty' if v.empty?

      unless v.empty?
        # let S' be a best state in V
        s_prime = nil
        max_f = nil
        s_prime_index = nil
        v.each_with_index do |s_prime_prime, i|
          f_s_prime_prime = f s_prime_prime, tutors
          next unless max_f.nil? || f_s_prime_prime >= max_f
          s_prime = s_prime_prime
          max_f = f_s_prime_prime
          s_prime_index = i
        end

        # let M' be the move that generated S'
        m_s = moves[s_prime_index]

        # 4) Test
        # puts '4'

        f_s_best = f(s_best, tutors)
        if f(s_prime, tutors) > f_s_best
          # found new best state, keep track of it
          s_best = s_prime
          # remember when state last improved
          tc_best = tc
        end

        # 5) Update
        # puts '5'

        # x and y are the swapped students
        x, y = m_s

        # update tabu time for students (t_x, t_y)
        t_students[x.id] = t_students[y.id] = tc

        # update current time and current state
        s = s_prime
      end

      # puts "max_f: #{f_s_best}"
      tc += 1
    end

    # No further improvement expected

    project_groups = convert_state_to_group_objects s_best, tutors
    @project.holding_pen.students.clear
    @project.groups.clear
    project_groups.each(&:save)

    [project_groups, k]
  end

  def greedy_allocate_reviews(project_groups, k)
    @project.reviews.each do |review|
      review.review_groups.each do |review_group|
        review_group.students.clear
      end
      review.holding_pen_review.students.clear

      students_by_project_tutor = {}
      project_groups.each do |project_group|
        students_by_project_tutor[project_group.tutor] = project_group.students.to_a
      end

      review.review_groups.each_with_index do |review_group, i|
        # Pick students to put in the review group until full
        k[i].times do
          # Find a student who's project tutor != this review_group's tutor
          students_by_project_tutor = Hash[students_by_project_tutor.to_a.shuffle] # shuffle the hash

          success = false
          students_by_project_tutor.except(review_group.tutor).each do |_, project_students|
            next if project_students.empty?
            review_group.students << project_students.shift
            success = true
            break
          end

          next if success

          # Couldn't choose a student that had a different project tutor to the current review group tutor so be greedy and have them anyway
          throw 'Run out of students to assign in review assignment' if students_by_project_tutor[review_group.tutor].empty?
          review_group.students << students_by_project_tutor[review_group.tutor].shift
        end
      end
    end
  end

  def convert_state_to_group_objects(state, tutors)
    groups = []
    state.each_with_index do |students, i|
      group = Group.new(tutor: tutors[i], project: @project)
      group.students = students
      groups << group
    end
    groups
  end

  def random_partition(array, k)
    k_sum = k.inject(:+)
    if k_sum == array.length
      partition = []
      array_shuffled = array.shuffle

      num_assigned = 0
      k.each do |num|
        partition << array_shuffled[num_assigned..(num + num_assigned - 1)]
        num_assigned += num
      end

      partition
    else
      throw "Array length and k total must be equal. Arr length=#{array.length}, k_sum=#{k_sum}"
    end
  end

  # Fitness function for a tabu search state (an array of groups)
  def f(groups, tutors)
    # Higher is better. The function takes into account many criteria, each of which is normalised.
    fitness = 0
    groups.each_with_index do |group, g_index|
      tutor = tutors[g_index]
      group.each do |student_x|
        group.each do |student_y|
          fitness += @alpha_ability_difference * ability_difference_criterion(student_x, student_y)

          # Compute this here even though it doesn't depend on student_y so as to maintain equal weighting discounting alphas
          fitness += @alpha_different_tutor * different_tutor_criterion(student_x, tutor)
        end
      end
    end

    fitness
  end

  # Computes the difference between student x and y and returns normalised version [0, 1]
  def ability_difference_criterion(x, y)
    diff = (x.ability_int - y.ability_int).abs
    diff.scale_between(0, MAX_ABILITY_DIFFERENCE, 0, 1)
  end

  # Applies a penalty if the tutors are the same. More of a penalty is applied if the student has had the specified tutor more often.
  def different_tutor_criterion(student, group_tutor)
    num_times_with_tutor, past_project_count = calc_num_times_with_tutor student, group_tutor

    # Student can only possibly have been with tutor past year equal to num past projects for year
    -num_times_with_tutor.scale_between(0, past_project_count, 0, 1) # note the negation
  end

  def calc_num_times_with_tutor(student, group_tutor, lookback_amount = 5)
    number_checked = 0
    num_times_with_tutor = 0
    student.groups.each do |g|
      next unless g.project.position_in_year < @project.position_in_year && number_checked <= lookback_amount
      num_times_with_tutor += 1 if g.tutor.id == group_tutor.id
      number_checked += 1
    end
    [num_times_with_tutor, number_checked]
  end

  # The k vector basically specifies how many students to put in each group
  def make_k_vector(num_students, num_groups)
    whole_num_students_per_group = (num_students / num_groups).to_i
    excess_students = num_students % num_groups

    # The following algorithm spreads the number of students between groups as evenly as possible
    k = []
    num_groups.times do
      num = whole_num_students_per_group
      if excess_students.positive?
        num += 1
        excess_students -= 1
      end
      k << num
    end

    k
  end
end

# Monkey patch numeric with new scale between method for normalisation of optimisation criteria
class Numeric
  def scale_between(from_min, from_max, to_min, to_max)
    ((to_max - to_min) * (to_f - from_min)) / (from_max - from_min) + to_min
  end
end
