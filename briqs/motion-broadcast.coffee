#motion-broadcast.coffee [andy.at.laughlinez.com]
#based upon the state.coffee/peek.coffee examples
#
#intent of this briq is to republish reading data containing 'motion' information as 'motion' events
#so that motion information is exposed in a simplified manner.
#both state.emit 'motion' AND  ss.api.publish.all 'ss-motion' events are generated
#so that they can be harvested by server and/or client-side code.
#
#To install this suite, copy motion-broadcast.coffee into housemon/briqs folder, and install from the 
#admin panel, changing the 'matches' parameter as required (defaults are set to pickup roomnode sketches)   


state = require '../server/state'
ss = require 'socketstream'

exports.info =
  name: 'motion-broadcast'
  description: 'Interrogate incomming readings and pick and broadcast relevant items as motion events'
  #menus: [
  #  title: 'MotionBroadcast'
  #]
  connections:
    feeds:
      'readings': 'collection'
    results:
      'motion': 'state event'
      'ss-motion': 'ss event'
  settings:
    #initcmds:
    #  title: 'Initial commands sent on startup'
    eventname:
      title: "The event to be broadcast, prefixed with 'recast.' e.g recast.motion and ss-recast.motion"
      default: 'motion'
    matches: 
      title: 'parameter names that should be matched, case in-sensitive'
      default: 'motion moved'

prefix = 'recast.'  
event_name = 'unnamed'
models = state.models

# TODO linear search, should be replaced by hash index
# TODO location and driver lookup depend on timestamp of the reading
findKey = (collection, key) ->
  for k,v of collection
    if key is v.key
      return v

matchlist = undefined

processReading = (obj, oldObj) ->
  if obj
    [locName, other..., drvName] = obj.key.split '.'

    loc = findKey models.locations, locName
    unless loc
      loc = findKey models.locations, drvName
      drvName = drvName?.replace /-.*/, ''
    drv = findKey models.drivers, drvName

    if loc and drv
      for param, value of _.omit obj, 'id','key','time'
        info = drv[param]

        isMotion = matchlist.some (paramname) -> ~param.toLowerCase().indexOf paramname
        if isMotion
          console.log 'We got motion for:', loc?.title, ' ', param, ' ',value   #locName=RF12:212:15 etc
          state.emit prefix + event_name, loc, param, value
          ss.api.publish.all 'ss-' + prefix + event_name, loc, param, value


exports.factory = class

  constructor: ->
    state.on 'set.readings', processReading
  destroy: ->
    state.off 'set.readings', processReading
  inited: ->
    #console.log "init for motion"
    matchlist = @matches.split ' ' if !matchlist?
    if @eventname == ''
      event_name = 'unnamed'
    else
      event_name = @eventname
 