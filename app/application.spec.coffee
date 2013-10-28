describe 'ApplicationController', ->
  controller = null
  scope = null

  beforeEach module 'boilerplate'
  beforeEach inject ($rootScope, $controller) ->
    scope = $rootScope.$new()
    controller = $controller 'ApplicationController',
      $scope: scope

  it 'says hello', ->
    assert.equal scope.message, 'Hello World!'
