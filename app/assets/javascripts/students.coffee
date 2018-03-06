#This is the coffee script for the course years inside admin area
$('body.students').ready ->
  $('.fancytable').DataTable
    'columns': [
      { className: 'first_name' },
      { className: 'last_name' },
      { className: 'registration_number' },
      { className: 'email' },
      { className: 'ability' },
      { className: 'overseas' },
      { className: 'course_year_id' },
      { className: 'course_id' },
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

  #Setup the slick manamement instance settings
  settings =
    objectName: 'student'
    datatableSelector: '.dataTable'
    uiName: 'Student'

  #Trigger slick manamement for the page
  slick = new App.SlickManagement settings