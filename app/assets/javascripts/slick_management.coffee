#This class sets up the ajax for admin pages, allowing for fully asynchronous management of things in the database.
class App.SlickManagement
  #These are the settings for the slick management class.
  #objectName: this is the name of the model in the ruby model
  #datatableSelector: this is the selector for the datatable
  #uiName: this is what the user should see the thing being refered to
  constructor: (settings) ->
    @objectName = settings.objectName
    @jsObjectName = settings.objectName.replace /_/, "-"
    @objectClassName = settings.objectName + 's'
    @datatableSelector = settings.datatableSelector
    @uiName = settings.uiName

    if typeof settings.extraDeleteMessage != undefined
      @extraDeleteMessage = settings.extraDeleteMessage

    @setupEdit()
    @setupDelete()
    @setupSave()

  #This sets up everything needed for the object to be edited
  setupEdit: ->
    self = this
    #This is for when the edit button is clicked in the table
    $(document).on 'click', '.edit-'+self.jsObjectName, ->
      currentID = $(this).closest('tr').data(self.jsObjectName+'-id')

      #This is a query to the database to get the object
      $.get '/'+self.objectClassName+'/' + currentID + '.json',
        (data) =>
          #This populates the modal
          $('#edit-' + self.jsObjectName + '-modal .modal-title').data(self.jsObjectName+'-id', data[self.objectName]["id"])
          $('.edit-' + self.jsObjectName + '-form').attr("action","/" +  self.objectClassName + "/"+data[self.objectName]["id"])
          fields = $('.edit-' + self.jsObjectName + '-form').find('*[id^=' + self.objectName + ']').not('.no-table')
          fields.each (current) ->
            $(this).val(data[self.objectName][$(this).attr("id").replace(self.objectName+'_', '')])
          $('#edit-' + self.jsObjectName + '-modal').modal('show')
          return

    #This allows the modal to be saved
    $('.save-' + self.jsObjectName).click ->
      currentID = $('#edit-' + self.jsObjectName + '-modal .modal-title').data(self.jsObjectName + '-id')
      row = 'tr[data-' + self.jsObjectName + '-id="' + currentID + '"] '
      table = $(self.datatableSelector).DataTable();
      data = table.row( $(row)).data()

      fields = $('.edit-' + self.jsObjectName + '-form').find('*[id^=' + self.objectName + ']').not('.no-table')
      fields.each (i) ->
        $(row + '.' + $(this).attr('id').replace(self.objectName+'_', '')).text(self.getValue($(this)))
        if (typeof data != 'undefined')
          data[i] = $(row + '.' + $(this).attr('id').replace(self.objectName+'_', '')).text()

      if (typeof data != 'undefined')
        table.row( $(row)).data(data)

      table.row( $('tr[data-' + self.jsObjectName + '-id="'+currentID+'"]')).invalidate().draw()
      $('#edit-' + self.jsObjectName + '-modal').modal('hide')
      $.flashAlert('Saved ' + self.uiName, 'alert-success')

  #This sets up everything needed to delete objects from the database
  setupDelete: ->
    self = this
    #Triggered when the object delete button is clicked
    $(document).on 'click', '.delete-'+self.jsObjectName, ->
      table = $(self.datatableSelector).DataTable();
      currentID = $(this).closest('tr').data(self.jsObjectName+'-id')
      that = this

      if typeof self.extraDeleteMessage != "undefined"
        text = self.extraDeleteMessage
      else
        text = 'Do you really want to delete this ' + self.uiName + '?'

      #The user is asked for confirmation
      dataConfirmModal.confirm
        title: 'Are you sure?'
        text: text
        commit: 'Confirm'
        cancel: 'Cancel'
        zIindex: 10099
        onConfirm: ->
          #the row is removed
          table.row( $('tr[data-' + self.jsObjectName + '-id="'+currentID+'"]')).remove().draw()
          #the object is deleted from the database
          $.ajax '/'+self.objectClassName+'/'+currentID,
            type: 'DELETE',
            (data) -> $.flashAlert('Deleted ' + self.uiName, 'alert-success')
          return
        onCancel: ->
          return

  #This sets up everything needed for the saving of a new object
  setupSave: ->
    self = this

    #This intercepts a form submit
    $('#new_' + self.objectName ).submit (e) ->
      e.preventDefault()
      table = $(self.datatableSelector).DataTable();
      generatedRowData = []

      fields = $('.new_' + self.objectName ).find('*[id^=' + self.objectName + ']').not('.no-table')
      fields.each (current) ->
        generatedRowData.push self.getValue($(this))
      generatedRowData.push('-', '-')

      #THis adds the new object to the table, with - in place of delete and edit
      newRow = table.row.add(generatedRowData).draw(false)

      #The modal is then hidden
      $('#new-' + self.jsObjectName + '-modal').modal('hide')

      #The new object is sent to the database
      $.ajax
        url: $('#new_' + self.objectName ).attr('action')
        type: 'post'
        data: $('#new_' + self.objectName ).serialize()
        success: (data, textStatus, jqXHR) ->
          #On success add the edit and delete buttons
          rowData = newRow.data()
          rowData[generatedRowData.length - 2] = '<a href="#" class="edit-' + self.jsObjectName + '">Edit</a>'
          rowData[generatedRowData.length - 1] = '<a href="#" class="delete-' + self.jsObjectName + '">Delete</a>'
          $(newRow.node()).attr('data-' + self.jsObjectName + '-id', data[ self.objectName ]["id"])
          newRow.invalidate().draw()
          $.flashAlert('Saved ' + self.uiName, 'alert-success')
          return
      false

  #This gets the value from a form object, in order to nicely handle (inputs, checkboxes, selected)
  getValue: (iObj) ->
    tag = iObj.prop("tagName")
    type = iObj.attr('type')
    if tag == 'INPUT' && !(type == 'checkbox')
      return iObj.val()
    else if (type == 'checkbox')
      return iObj.is(':checked')
    else
      return iObj.find(":selected").text();