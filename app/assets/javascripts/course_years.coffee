#This is the coffee script for the course years inside the admin area

$('body.course_years').ready ->
  #This setsup the data table so it is searchable
  $('.fancytable').DataTable
    'columns': [
      { className: 'name' },
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
    objectName: 'course_year'
    datatableSelector: '.dataTable'
    uiName: 'Course Year'
    extraDeleteMessage: 'By deleting this course year, you will remove all associated <strong>students</strong>, <strong>tutors</strong>, <strong>projects</strong> and <strong>year leaders</strong> <br/><br/> Any generated groups or review groups will <strong> not </strong> be recoverable! <br/><br/> Are you sure you want to do this?'
  #Trigger the SlickManamgement for the page
  slick = new App.SlickManagement settings