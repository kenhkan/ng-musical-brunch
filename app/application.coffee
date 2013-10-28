# Define the module and dependencies
module = angular.module '$PROCESS_ENV_APP_NAME'

# Root controller
module.controller 'ApplicationController', ($scope, $location) ->
  $scope.message = 'Hello World!'
