exports.info =
  name: 'tanknode'
  description: 'This demo Tanknode briq is used by the "Dive Into JeeNodes" series'
  menus: [
    title: 'TankNode'
    controller: 'TankNodeCtrl'
  ]
  connections:
    feeds:
      'rf12.packet': 'event'
    results:
      'ss-tank-demo': 'event'

state = require '../server/state'
ss = require 'socketstream'

exports.factory = class
  
  constructor: ->
    state.on 'rf12.packet', packetListener
        
  destroy: ->
    state.off 'rf12.packet', packetListener

packetListener = (packet, ainfo) ->
  if packet.id is 8 and packet.group is 212
    value = packet.buffer[1]
    ss.api.publish.all 'ss-tank-demo', value
