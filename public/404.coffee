do ->
  # Define the module and dependencies
  module = angular.module 'boilerplate', [
    'ui.state'
    'ui.route'
    'titleService'
  ]

  # Routing
  module.config ($locationProvider, $stateProvider, $urlRouterProvider) ->
    # Use HTML5 mode
    $locationProvider.html5Mode true

    # Redirection rules
    $urlRouterProvider.otherwise '/'

  # Entry point
  module.run (titleService) ->
    titleService.setSuffix ' | Boilerplate'

  # Root controller
  module.controller 'AppController', ($scope, $location) ->
    $scope.message = 'Hello!'
