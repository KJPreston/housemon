# Peek module definitions

module.exports = (ng) ->

  ng.controller 'Rf12inputCtrl', [
    '$scope',
    ($scope) ->
      $scope.$on 'ss-peek', (event, args...) ->
        console.log 'peek', args...
  ]
