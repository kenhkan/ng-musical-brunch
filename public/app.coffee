do ->
  # Define the module and dependencies
  module = angular.module 'boilerplate'

  # Root controller
  module.controller 'AppController', ($scope, $location) ->
    $scope.message = 'Hello!'
