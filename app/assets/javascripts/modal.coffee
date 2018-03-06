#Auto select on modal
$ ->
  $(document).on 'ajax-modal-show', ->
    $('select.select2').select2()