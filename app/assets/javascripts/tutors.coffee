#This is the coffee script for the tutors in the admin area
$('body.tutors').ready ->
  $('.fancytable').DataTable
    'columns': [
      { className: 'first_name' },
      { className: 'last_name' },
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
    objectName: 'tutor'
    datatableSelector: '.dataTable'
    uiName: 'Tutor'

  #Trigger the SlickManamgement for the page
  slick = new App.SlickManagement settings