# Peek module definitions

module.exports = (ng) ->

  ng.controller 'PeekCtrl', [
    '$scope',
    ($scope) ->
      $scope.$on 'ss-peek', (event, args...) ->
        console.log 'peek-event', event
        console.log 'peek', args...

#        console.log 'peek-args0', args[0]
#        if args[0] == 'publish'
#           console.log 'peek-was-publish'
#           if args[1] == 'status'
#             console.log 'peek-was-publish-status'
#             if args[2]?.parameter == 'Motion'
#               if  args[2].parameter == 'Motion'
#                 console.log 'Motion was:',args[2].value 


  ]
