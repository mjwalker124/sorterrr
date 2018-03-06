#This is the coffee for the reviews area
$('body.projects.reviews').ready ->
  #Setup the group management for the reviews using the ReviewGroups class
  reviewGroups = new App.ReviewGroups()

  #This allows a review to be deleted
  $(document).on 'tap click', '.delete-review', (e) ->
    e.stopPropagation
    e.preventDefault
    that = this
    #This asks for confirmation
    dataConfirmModal.confirm
      title: 'Are you sure?'
      text: 'Do you really want to delete this review?'
      commit: 'Confirm'
      cancel: 'Cancel'
      zIindex: 10099
      onConfirm: ->
        $(that).parents('a').removeAttr('href')
        $(that).parents('li').remove()
        reviewId = $(that).data('review-id')
        $.post '/reviews/delete/'+reviewId,
          id: reviewId
          (data) -> $.flashAlert('Deleted Review', 'alert-success')
        return
      onCancel: ->
        return
    return false

  #This allows add review
  $('.add-review').click (e) ->
    e.preventDefault
    project = $('h2.project-name').data('project-id')
    $.post '/reviews',
      project_id: project
      (data) ->
        $.flashAlert('Added Review', 'alert-success')
        #Add the tab to the reviews bar
        $('.add-tab').before('<li><a href="/projects/reviews/'+project+'/'+data["review_id"]+'"> Review '+data["position_in_project"]+' <i class="delete-review fa fa-trash" data-review-id="'+data["review_id"]+'"></i></a></li>')

  #Allow groups to be reset
  $('#btn-reset-groups').click ->
    $.flashAlert('Resetting groups...', 'alert-info')
    reviewId = $('h2.project-name').data('review-id')
    $.post '/reviews/' + reviewId + '/reset_groups', (data) ->
      location.reload()

  #Randomize groups
  $('#randomize-groups').click ->
    $.flashAlert('Randomising groups..', 'alert-info')
    reviewId = $('h2.project-name').data('review-id')
    $.post '/reviews/' + reviewId + '/randomize', (data) ->
      location.reload()
