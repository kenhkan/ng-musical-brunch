do ->
  # Define the module and dependencies
  module = angular.module 'boilerplate', [
    'ui.state'
    'ui.route'
  ]

  # Routing
  module.config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise '/home'

  # Entry point
  module.run (titleService) ->
    titleService.setSuffix ' | Boilerplate'

  # Root controller
  module.controller 'AppController', ($scope, $location) ->
    $scope.message = 'Hello Harp!'
