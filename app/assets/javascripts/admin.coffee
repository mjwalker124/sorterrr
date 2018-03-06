#admin.coffee
#This contains the coffee script required for the admin page - delete data
$('body.admin.delete_data').ready ->
  #This is called when the user clicks delete data
  $('#btn-delete-data').click ->
    #This shows a confirm modal to make sure that the user does want to delete the data
    dataConfirmModal.confirm
      title: 'Are you sure?'
      text: 'Do you really want to permanently delete all projects, students, groups and reviews?'
      commit: 'Confirm'
      cancel: 'Cancel'
      zIindex: 10099
      onConfirm: ->
        $.flashAlert('Deleting data. This could take a few minutes. You will get a notification when complete.', 'alert-info', 10000)
        $.post '/admin/delete-data', (data) ->
          $.flashAlert('Successfully deleted data.', 'alert-success')
      onCancel: ->