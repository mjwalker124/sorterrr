#This is the coffee script for the users inside the admin area

$('body.users').ready ->

  #This allows the password to be validated inside html5 validation
  password = document.getElementById('user_password')
  confirm_password = document.getElementById('user_password_confirmation')

  validatePassword = ->
    if password.value != confirm_password.value
      confirm_password.setCustomValidity 'Passwords Don\'t Match'
    else
      confirm_password.setCustomValidity ''
    return
  password.onchange = validatePassword
  confirm_password.onkeyup = validatePassword

  #This setsup the data table so it is searchable
  $('.fancytable').DataTable
    'columns': [
      { className: 'email' },
      { className: 'course_year_id' },
      {},
      {}
    ],
    'columnDefs': [ {
      'searchable': false
      'orderable': false
      'targets': [
        -1
        -2
      ]
    } ]

  #Setup the SlickManamgement instance settings
  settings =
    objectName: 'user'
    datatableSelector: '.dataTable'
    uiName: 'Year Leaders'

  #Trigger the SlickManamgement for the page
  slick = new App.SlickManagement settings