module.exports =

  announcer: 32

  descriptions:
    hw:
      title: 'HW Circuit'
      unit: 'on/off'
      min: 0
      max: 1
    hwv:
      title: 'HW Valve'
      unit: 'on/off'
      min: 0
      max: 1
    ch:
      title: 'CH Circuit'
      unit: 'on/off'
      min: 0
      max: 1
    chv:
      title: 'CH Valve'
      unit: 'on/off'
      min: 0
      max: 1
    z2v:
      title: 'Zone2 Valve'
      unit: 'on/off'
      min: 0
      max: 1
    blc:
      title: 'Boiler Circuit'
      unit: 'on/off'
      min: 0
      max: 1
    bls:
      title: 'Boiler Status'
      unit: 'on/off'
      min: 0
      max: 1



  feed: 'rf12.packet'

  decode: (raw, cb) ->
    cb
      hw: if raw[1] then 0 else 1 #invert logic
      hwv: raw[2] 
      ch: if raw[3] then 0 else 1 #invert logic
      chv: raw[4]
      z2v: raw[5]
      blc: raw[6]
      bls: raw[7]
