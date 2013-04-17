state = require '../server/state'

exports.info =
  name: 'rf12demo-rw'
  description: 'Read/Write Serial interface for a JeeNode running the RF12demo sketch'
  inputs: [
    name: 'Serial port'
    default: 'usb-AH01A0GD' # TODO: list choices with serialport.list
  ]
  connections:
    packages:
      'serialport': '*'
    results:
      'rf12.announce': 'event'
      'rf12.packet': 'event'
      'rf12.config': 'event'
      'rf12.other': 'event'
  settings:
    initcmds:
      title: 'Initial commands sent on startup'
    inputfor:
      title: 'Frequency/netgroups to listen for write requests - use f to signify current band and n for netgroup' + '[' + (state.wildcard == true) + ']'
      default: 'f/n'

serialport = require 'serialport'

class RF12demorw extends serialport.SerialPort

  writefor: []
  allow_rf12config: true
  config: {}
  writeq: []

  constructor: (@device) ->
    # support some platform-specific shorthands
    switch process.platform
      when 'darwin' then port = device.replace /^usb-/, '/dev/tty.usbserial-'
      when 'linux' then port = device.replace /^tty/, '/dev/tty'
      else port = device
    
    # construct the serial port object
    baud = 57600
    if device == 'ttyAMA0'
       baud = 38400
    super port,
      baudrate: baud
      parser: serialport.parsers.readline '\n'
    console.info "Port:" + port + " Baud:" + baud
 
  rf12config: (allowed) =>
    console.log "rf12config set:" + allowed
    @allow_rf12config = allowed

  flushed: (err, result) =>
    console.log "Flushed"


  send: (data, band, group) =>
    console.log 'send', band, group, data
    #add command to write q
    entry = 
      data: data, 
      band: band, 
      group: group
    @writeq.push entry
    #q = @writeq.pop()

    console.log "Master config band:" + @config.band + " group:" + @config.group + " device:" + @device
    #see if we need to switch group/band
    chb = @config.band  != band
    chn = @config.group != group
    if chb 
      console.log "Change band:" + band.slice(0,1) + ' b\n'
      @write band.slice(0,1) + ' b\n'
    if chn
      console.log "switching group:" + group + "<<<<<<<<<<<<<<<<"
      @write group + ' g\n'


    #@write '212 g'
    #@write '8 b'

    @write data + "\r\n"
    console.log "Q:" + entry.data  + '\n'


    if chb
      console.log "Revert Change band:" + @config.band.slice(0,1) + ' b'
      @write @config.band.slice(0,1) + ' b\n'
    if chn
      @write @config.group + ' g\n'
      console.log "revert group...." + @config.group

    return true

  inited: ->
    
    @on 'open', =>
      console.log "Port open..." + @device
      setTimeout =>
        @write @initcmds
      , 1000
      setTimeout =>
        @write '?\r\n'
      , 1100

      info = {}
      ainfo = {}


      #does our instance have identity, if so we can listen for writes
      state.on 'rf12.config', (device, data, match) =>
        console.log "event: rf12.config:" + device + "->" + @device
        if @device != device
          return

        if @allow_rf12config 
          @config.group = match[1]
          @config.band = match[2]
          if @config?.band and @config?.group
            @rf12config false #ignore further config events
            #unwind previous input listeners that this instance listened for.
            for v in @writefor
              console.log "Unbind:" + v.name
              state.off v.name, v.func

            @writefor = [] #now clear down internal db

            for v,i in @inputfor.split ' '  #and reinstate from the initial startup instance params
              v = v.replace /f/,info.band
              v = v.replace /n/,info.group
              v = v.replace /\//,'.'
              v = 'rf12.input' + '.' + v
              #see if we have a listener already
              if state.listeners(v)?[0] 
                console.log 'duplicate listener' + v  + " for " + @device      
              else
                @writefor[i] = {name:v,func:{}}   #rebuild our listener db for this instance
                @writefor[i].func = (data)->
                  console.log "rf12.input data:" + data 
                  console.log '>>>>>>rf12.input ....' + @event
                  aevent = @event.split '.'
                  j = self.send(data, aevent[2],aevent[3])
                  console.log '>>>>>>rf12.input: ', j
                console.log "listening on :" + v + " for " + @device
                self = @
                state.on @writefor[i].name, @writefor[i].func  #and start listening for events
        else
          console.log "config disabled..."

      state.on 'rf12.sendcomplete', (device, bytes) =>
        if device != @device
          return

        entry = @writeq.pop()
        if entry
          console.log "Sendcomplete for:" + device + ' ' + entry.band + '/' + entry.group + ' ' + entry.data + " with bytes:" + bytes
        else
          console.log "Sendcomplete for:" + device + " with bytes:" + bytes
        #@rf12config (@writeq.length == 0)

  
      @on 'data', (data) ->
        #console.log ">Data Event:" + data
        data = data.slice(0, -1)  if data.slice(-1) is '\r'
        if data.length < 300 # ignore outrageously long lines of text
          # broadcast raw event for data logging
          state.emit 'incoming', 'rf12demo', @device, data
          words = data.split ' '
          if words.shift() is 'OK' and info.recvid
            # TODO: conversion to ints can fail if the serial data is garbled
            info.id = words[0] & 0x1F
            info.buffer = new Buffer(words)
            if info.id is 0
              # announcer packet: remember this info for each node id
              aid = words[1] & 0x1F
              ainfo[aid] ?= {}
              ainfo[aid].buffer = info.buffer
              state.emit 'rf12.announce', ainfo[aid]
            else
              # generate normal packet event, for decoders
              state.emit 'rf12.packet', info, ainfo[info.id]
          else
            match = /^ -> (\d+) b/.exec data
            if match #we have results of a send from the mcu in the format ' -> x b' where x is bytes.
               state.emit 'rf12.sendcomplete', @device, match[1]
            else
              # look for config lines of the form: A i1* g5 @ 868 MHz
              match = /^ [A-Z[\\\]\^_@] i(\d+)\*? g(\d+) @ (\d\d\d) MHz/.exec data
              if match
                console.log ">config match:" , data
                info.recvid = parseInt(match[1])
                info.group = parseInt(match[2])
                info.band = parseInt(match[3])
                state.emit 'rf12.config', @device, data, match.slice(1)
              else
                # unrecognized input, usually a "?" line
                state.emit 'rf12.other', data
                console.info 'other', @device, data
          
  destroy: -> 
    @close()
    for v,i in @writefor
      console.info "+++++++++" + v
      state.off v.name,v.func
        
exports.factory = RF12demorw
