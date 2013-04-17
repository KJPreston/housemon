module.exports = (ng) ->

  ng.controller 'TankNodeCtrl', [
    '$scope',
    ($scope) ->
      $scope.$on 'ss-tank-demo', (event, value) ->
        $scope.value = value
  ]
