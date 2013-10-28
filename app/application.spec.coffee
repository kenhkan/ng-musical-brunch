describe 'ApplicationController', ->
  controller = null
  scope = null

  beforeEach angular.mock.module '$PROCESS_ENV_APP_NAME'
  beforeEach inject ($rootScope, $controller) ->
    scope = $rootScope.$new()
    controller = $controller 'ApplicationController',
      $scope: scope

  it 'says hello', ->
    expect(scope.message).toEqual 'Hello World!'
