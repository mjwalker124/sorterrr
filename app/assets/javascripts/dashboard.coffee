# This is all coffee script for the dashboard
$('body.dashboard.index').ready ->
  $.ajaxSetup dataType: 'json'

  #Handle ajax response on the form
  $(document).on("ajax:success", (e, data, status, xhr) ->
    window.location.href = "/projects/"+data.id
  ).on("ajax:error", (e, data, status, xhr) ->
    $("#new_project").render_form_errors('project', data.responseJSON)
  )

  #This renders the form errors
  $.fn.render_form_errors = (model_name, errors) ->
    form = this
    this.clear_form_errors()

    $.each(errors, (field, messages) ->
      input = form.find('input, select, textarea').filter(->
        name = $(this).attr('name')
        if name
          name.match(new RegExp(model_name + '\\[' + field + '\\(?'))
      )
      input.closest('.form-group').addClass('has-error')
      input.parent().append('<span class="help-block">' + $.map(messages, (m) -> m.charAt(0).toUpperCase() + m.slice(1)).join('<br />') + '</span>')
    )

  #Clears errors
  $.fn.clear_form_errors = () ->
    this.find('.form-group').removeClass('has-error')
    this.find('span.help-block').remove()

  #Clear values in flields
  $.fn.clear_form_fields = () ->
    this.find(':input','#myform')
      .not(':button, :submit, :reset, :hidden')
      .val('')
      .removeAttr('checked')
      .removeAttr('selected')

  $('#search').hideseek
    attribute: 'data-project-name'

  # On pill/tab change
  $('a[data-toggle="pill"]').on 'shown.bs.tab', (e) ->
    # Rebind the search
    $('#search').off().hideseek()

  # For testing
  $('a.disabled').click (e) ->
    e.preventDefault()


  #Handle to page load with a tab pre opened
  target = window.location.href.split('#')
  if typeof target[1] == 'undefined'
    $('.nav-pills a[href="#tab_year' + $('#user-menu').data('user-year-id') + '"]').tab('show');
  else
    $('.nav-pills a[href="#' + target[1] + '"]').tab('show');