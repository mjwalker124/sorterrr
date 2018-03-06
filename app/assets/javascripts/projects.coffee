#handle for script for projects

#Setup close the stream
App.stop_task = ->
  eSource.close()
  return

#Store defaults for the queue
App.blocked = false
App.queue_size = 0
App.first_iteration = true

#Setup stream data
App.start_task = ->
  App.blocked = $('#recalculation-progress').hasClass('hidden')

  projectId = $('h2.project-name').data('project-id')
  eSource = new EventSource('/allocation_job/project_info/'+projectId)
  eSource.addEventListener 'message', ((e) ->
    result = JSON.parse(e.data)
    console.log e.data
    App.handleCurrent result.auto_allocate_blocked, result.auto_allocate_queue_size

    #Do whatever with e.data
    return
  ), false
  return

#Handle the current streamed data
App.handleCurrent = (blocked, queue_size) ->
#console.log current
  if blocked != App.blocked
    if !blocked
      $('#recalculation-progress').removeClass('hidden')
      $('#btn-recalculate-groups').removeClass('hidden')
      $('#recalculation-progress').addClass('hidden')
    else
      $('#recalculation-progress').removeClass('hidden')
      $('#btn-recalculate-groups').removeClass('hidden')
      $('#btn-recalculate-groups').addClass('hidden')

  #Check if the queue size has changed
  if queue_size != App.queue_size
    $('.queue_size').text(queue_size)

  if queue_size != App.queue_size || blocked != App.blocked
    #Make sure it isn't the first load
    if !App.first_iteration
      if queue_size < App.queue_size
        $.flashAlert('An auto-allocation has been completed. Reloading page.', 'alert-success')
        audio = new Audio('/sound/update.mp3')
        audio.play()
        location.reload()
      else
        $.flashAlert('A new auto-allocation has been triggered', 'alert-info')
    else
      App.first_iteration = false

    #Update the store
    App.blocked = blocked
    App.queue_size = queue_size
  return

$('body.projects.show').ready ->
  #Get instance of the project groups in group_management.coffee
  projectGroups = new App.ProjectGroups()
  #Start streaming
  App.start_task()

  #Reset groups post
  $('#btn-reset-groups').click ->
    $.flashAlert('Resetting groups...', 'alert-info')
    projectId = $('h2.project-name').data('project-id')
    $.post '/projects/' + projectId + '/reset_groups', (data) ->
      location.reload()

  #This is so the user can set the default settings
  $('#allocate-options-modal form').submit (e) ->
    $.flashAlert('Queuing your allocation job...', 'alert-info')
    projectId = $('h2.project-name').data('project-id')
    $.post '/projects/' + projectId + '/auto_allocate', $(e.target).serialize(), (data) ->
      $('#allocate-options-modal').modal('hide')
    return false # stop form from submitting (e.preventDefault() didn't seem to work)

  #This triggers a randomize groups
  $('#randomize-groups').click ->
    $.ajax '/projects/randomize/'+$('h2.project-name').data('project-id'),
      type: 'post'
      dataType: 'ajax'
      complete: (data, textStatus, jqXHR) ->
        location.reload()

  #This triggers a greedy approach
  $('#good-fit-groups').click ->
    $.ajax '/projects/good_fit/'+$('h2.project-name').data('project-id'),
      type: 'post'
      dataType: 'ajax'
      complete: (data, textStatus, jqXHR) ->
        location.reload()

