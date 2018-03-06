#The is the base class coffee for all group manamement
class App.GroupManagementClass
  constructor: ->
    currentName = null
    mouseOnCurrentName = false
    mouseDownOnCurrentName = false
    @setGroupMemberTooltips()
    @setSideMenuTooltips()
    @setupMouseChecks()
    @setupGoupContainers()
    @setupTapGroupMember()
    @setupGroupMemberMouseDown()
    @setupProjectRenaming()
    @setupSettingCurrentGrade()

  #Allow group to be set as a warning level
  alert: (object, state) ->
    panel = object
    # Remove the existing panel state
    $(panel).removeClassRegex /^panel-/
    $(panel).addClass 'panel-' + state

  redAlert: (groupID) ->
    this.alert groupID, 'danger'

  amberAlert: (groupID) ->
    this.alert groupID, 'warning'

  #This removes all alerts
  clearAllAlerts: ->
    panels = $('.group > .panel')
    panels.removeClassRegex /^panel-/
    panels.addClass 'panel-default'

  #This removes a single alert
  clearAlert: (groupID) ->
    alert groupID, 'default'

  #This adds the students past tutors to the table in the side bar
  updatePastStaffTable: (pastStudentReviewers, pastStudentTutors) ->
    if pastStudentReviewers.length > pastStudentTutors.length
      max = pastStudentReviewers.length
    else
      max = pastStudentTutors.length

    tableHtml = ""
    for i in [0..(max-1)]
      if pastStudentReviewers[i] is undefined
        pastStudentReviewers[i] = ""
      if pastStudentTutors[i] is undefined
        pastStudentTutors[i] = ""
      tableHtml += "<tr><td>" + pastStudentReviewers[i] + "</td><td>" + pastStudentTutors[i] + "</td></tr>"
    $('table.table tbody.previous_staff_relations').html(tableHtml)

  # http://stackoverflow.com/a/18621161
  $.fn.removeClassRegex = (regex) ->
    $(this).removeClass (index, classes) ->
      classes.split(/\s+/).filter((c) ->
        regex.test c
      ).join ' '

  #Setup tooltips for group members
  setGroupMemberTooltips: ->
    $('.group-member').tooltip position:
      my: 'center bottom'
      at: 'center top'

  #Setup tool tips for the icon bar
  setSideMenuTooltips: ->
    $('.icon-bar').tooltip position:
      my: 'top+10'
      at: 'bottom'

  #this makes sure that the tool tips and alerts are clean when the client stops their click
  setupMouseChecks: ->
    that = this
    $('.group-member').mouseup ->
      that.mouseDownOnCurrentName = false
      that.clearAllAlerts()
    $('.group-member').mouseout ->
      that.mouseOnCurrentName = false
      $('.ui-tooltip').remove()

  #This will be over written in the extension classes
  setupTapGroupMember: ->

  #This will be over written in the extension classes
  setupGroupMemberMouseDown: ->

  #Setup drag and drop between group members and the groups/holding pen
  setupGoupContainers: ->
    that = this
    $('.holding-pen').sortable
      connectWith: '.group .row, .holding-pen'
      receive: (event, ui) ->
        that.updateGroups event
        return
    $('.holding-pen').disableSelection()
    $('.group .row').sortable
      revert: true
      connectWith: '.group .row, .holding-pen'
      receive: (event, ui) ->
        that.updateGroups event
        return
    $('.group .row').disableSelection()

  #This will be over written in the extension classes
  updateGroups: (event) ->

  #This allows groups to be renamed nicely in a google docs style
  setupProjectRenaming: ->
    $('#project-name-input').blur (e) ->
      projectName = $(this).val()
      projectId = $('h2.project-name').data('project-id')

      $.ajax '/projects/' + projectId,
        type: 'PATCH'
        dataType: 'ajax'
        data: {project: {name: projectName}}
        complete: (data, textStatus, jqXHR) ->
          $.flashAlert('Updated project name', 'alert-success')

  #This allows the grade to be set in a similar style to google docs rename style
  setupSettingCurrentGrade: ->
    $('#current-grade-input').blur (e) ->
      currentGrade = $(this).val()
      studentId = $('.student-name').data('student-id')
      if typeof studentId != 'undefined'
        $.ajax '/students/' + studentId,
          type: 'PATCH'
          dataType: 'ajax'
          data: {student: {ability: currentGrade}}
          complete: (data, textStatus, jqXHR) ->


#This is the class for project groups which extends group manamement
class App.ProjectGroups extends App.GroupManagementClass
  #This saves the group which has just been changed
  updateGroups: (event) ->
    that = this
    $.ajax '/projects/student_group',
      type: 'POST'
      dataType: 'ajax'
      data: {project_id: $('h2.project-name').data('project-id'), student_id: that.currentName.data("student-id"), old_group_id: that.currentName.data("group-id"), new_group_id: $(event.target).data("group-id")}
      complete: (data, textStatus, jqXHR) ->
        $(that.currentName).data("group-id", $(event.target).data("group-id"))

  #This controls the response to a student being clicked on
  setupTapGroupMember: =>
    App.student_cache = []
    App.current_student_id = null
    that = this
    $('.group-member').mousedown ->
      self = $(this)
      #This saves the grade update
      $('#current-grade-input').trigger("blur")
      that.mouseOnCurrentName = true
      that.mouseDownOnCurrentName = true
      that.currentName = $(this)

      studentId = $(this).data('student-id')
      App.current_student_id = studentId

      #Check to see if the clicked on student is in the cache, if they do use it
      if (typeof App.student_cache[studentId] != "undefined")
        data = App.student_cache[studentId]
        $('.student-name').text(data["student"]["first_name"] + ' ' + data["student"]["last_name"])
        $('.student-email').text(data["student"]["email"])
        $('#current-grade-input').val(data["student"]["ability"])
        $('.student-registration-number').text(data["student"]["registration_number"])
        $('.person-img').attr('src', data["image_url"])
        $('.student-course-name').text('Course Name: ' + data["course_name"])
        $('.student-overseas').text(if data["student"]["overseas"] then "Overseas" else "Home")
        reviewerIds = data["reviewer_ids"]
        reviewerIds.forEach (d, i) ->
          currentElement = '*[data_tutor_id="' + d + '"] div:first'
          if that.mouseOnCurrentName && that.mouseDownOnCurrentName
            (that.redAlert) currentElement

        tutorsIds = data["tutor_ids"]
        tutorsIds.forEach (d, i) ->
          currentElement = '*[data_tutor_id="' + d + '"] div:first'
          if that.mouseOnCurrentName && that.mouseDownOnCurrentName
            (that.amberAlert) currentElement

        that.updatePastStaffTable data["reviewers"], data["tutors"]
      else
        #If no cache then use default values while waiting for info
        $('.student-name').text($(this).text())
        $('.student-email').text('-')
        $('.student-registration-number').text('-')
        $('.student-course-name').text('Course Name: -')
        $('.student-overseas').text('-')
        $('#current-grade-input').val('-')

      projectId = $('h2.project-name').data('project-id')
      groupId = $(that.currentName).data("group-id")
      $('.student-name').data('student-id', studentId)

      #Get the info for the students from the database
      $.get '/students/' + studentId + '.json', {review: false, project_id: projectId, current_group: groupId},
        (data) =>
          if (typeof App.student_cache[studentId] == "undefined")
            App.student_cache[studentId] = data

          #Make sure the student downloaded is the currently active one then update the ui
          if (App.current_student_id.toString() == studentId.toString())
            $('.student-name').text(data["student"]["first_name"] + ' ' + data["student"]["last_name"])
            $('.student-email').text(data["student"]["email"])
            $('#current-grade-input').val(data["student"]["ability"])
            $('.student-registration-number').text(data["student"]["registration_number"])
            $('.person-img').attr('src', data["image_url"])
            $('.student-course-name').text('Course Name: ' + data["course_name"])
            $('.student-overseas').text(if data["student"]["overseas"] then "Overseas" else "Home")
            reviewerIds = data["reviewer_ids"]
            reviewerIds.forEach (d, i) ->
              currentElement = '*[data_tutor_id="' + d + '"] div:first'
              if that.mouseOnCurrentName && that.mouseDownOnCurrentName
                (that.redAlert) currentElement

            tutorsIds = data["tutor_ids"]
            tutorsIds.forEach (d, i) ->
              currentElement = '*[data_tutor_id="' + d + '"] div:first'
              if that.mouseOnCurrentName && that.mouseDownOnCurrentName
                (that.amberAlert) currentElement

            that.updatePastStaffTable data["reviewers"], data["tutors"]

#This is the class for reviews groups which extends group manamement
class App.ReviewGroups extends App.GroupManagementClass
  #This saves the group which has just been changed
  updateGroups: (event) =>
    that = this
    $.ajax '/projects/student_review_group',
      type: 'POST'
      dataType: 'ajax'
      data: {
        review_id: $('h2.project-name').data('review-id'),
        student_id: that.currentName.data("student-id"),
        old_group_id: that.currentName.data("group-id"),
        new_group_id: $(event.target).data("group-id")
      }
      complete: (data, textStatus, jqXHR) =>
        $(that.currentName).data("group-id", $(event.target).data("group-id"))

  #This controls the response to a student being clicked on
  setupTapGroupMember: ->
    that = this
    App.student_cache = []
    App.current_student_id = null
    $('.group-member').mousedown ->
      self = $(this)
      $('#current-grade-input').trigger("blur")
      studentId = $(this).data('student-id')
      App.current_student_id = studentId
      that.mouseOnCurrentName = true
      that.mouseDownOnCurrentName = true
      that.currentName = $(this)
      #Check to see if the clicked on student is in the cache, if they do use it
      if (typeof App.student_cache[studentId] != "undefined")
        data = App.student_cache[parseInt(studentId)]
        $('.student-name').text(data["student"]["first_name"] + ' ' + data["student"]["last_name"])
        $('.student-email').text(data["student"]["email"])
        $('#current-grade-input').val(data["student"]["ability"])
        $('.student-registration-number').text(data["student"]["registration_number"])
        $('.person-img').attr('src', data["image_url"])
        $('.student-course-name').text('Course Name: ' + data["course_name"])
        $('.student-overseas').text(if data["student"]["overseas"] then "Overseas" else "Home")
        reviewerIds = data["reviewer_ids"]
        reviewerIds.forEach (d, i) ->
          currentElement = '*[data_tutor_id="' + d + '"] div:first'
          if that.mouseOnCurrentName && that.mouseDownOnCurrentName
            (that.amberAlert) currentElement

        tutorsIds = data["tutor_ids"]
        tutorsIds.forEach (d, i) ->
          currentElement = '*[data_tutor_id="' + d + '"] div:first'
          if that.mouseOnCurrentName && that.mouseDownOnCurrentName
            (that.redAlert) currentElement

        that.updatePastStaffTable data["reviewers"], data["tutors"]
      else
        #If no cache then use default values while waiting for info
        $('.student-name').text($(this).text())
        $('.student-email').text('-')
        $('.student-registration-number').text('-')
        $('.student-course-name').text('Course Name: -')
        $('.student-overseas').text('-')
        $('#current-grade-input').val('-')


      projectId = $('h2.project-name').data('project-id')
      reviewId = $('h2.project-name').data('review-id')
      groupId = $(that.currentName).data("group-id")
      $('.student-name').data('student-id', studentId)
      $.get '/students/' + studentId + '.json', {review: true, project_id: projectId, current_group: groupId, review_id: reviewId},
        (data) =>
          if (typeof App.student_cache[data["student"]["id"]] == "undefined")
            App.student_cache[data["student"]["id"]] = data

          #Make sure the student downloaded is the currently active one then update the ui
          if (App.current_student_id.toString() == studentId.toString())
            $('.student-name').text(data["student"]["first_name"] + ' ' + data["student"]["last_name"])
            $('.student-email').text(data["student"]["email"])
            $('#current-grade-input').val(data["student"]["ability"])
            $('.student-registration-number').text(data["student"]["registration_number"])
            $('.student-course-name').text('Course Name: ' + data["course_name"])
            $('.student-overseas').text(if data["student"]["overseas"] then "Overseas" else "Home")
            $('.person-img').attr('src', data["image_url"])
            reviewerIds = data["reviewer_ids"]
            reviewerIds.forEach (d, i) ->
              currentElement = '*[data_tutor_id="' + d + '"] div:first'
              if that.mouseOnCurrentName && that.mouseDownOnCurrentName
                (that.amberAlert) currentElement

            tutorsIds = data["tutor_ids"]
            tutorsIds.forEach (d, i) ->
              currentElement = '*[data_tutor_id="' + d + '"] div:first'
              if that.mouseOnCurrentName && that.mouseDownOnCurrentName
                (that.redAlert) currentElement

            that.updatePastStaffTable data["reviewers"], data["tutors"]
