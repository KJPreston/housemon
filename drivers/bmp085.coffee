module.exports =

  announcer: 101

  descriptions:
    temp:
      title: 'Temperature'
      unit: '°C'
      scale: 1
      min: -50
      max: 50
    pressure:
      title: 'Pressure'
      unit: 'hPa'
      scale: 2
    lobat:
      title: 'Low battery'
      unit: 'boolean'
        
  feed: 'rf12.packet'

  decode: (raw, cb) ->
    t = raw.readUInt16LE(1, true) 
    cb
      temp: t
      pressure: raw.readUInt32LE(3, true)
      lobat: raw[7]
