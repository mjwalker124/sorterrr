#This is the coffee script for the courses inside the admin area

$('body.courses').ready ->
  #This setsup the data table so it is searchable
  $('.fancytable').DataTable
    'columns': [
      { className: 'name' },
      { className: 'code' }
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
    objectName: 'course'
    datatableSelector: '.dataTable'
    uiName: 'Course'

  #Trigger the SlickManamgement for the page
  slick = new App.SlickManagement settings