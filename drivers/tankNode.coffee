module.exports =

  announcer: 31

  descriptions:
    ['HWTANK','HWTANKLEAK']

  HWTANK:
    temp:
      title: 'Temperature'
      unit: '°C'
      scale: 2
    batt:
      title: 'Battery'
      unit: 'V'
      scale: 3

  HWTANKLEAK:
    adc:
      title: 'ADC'
      unit: 'V'
      scale: 0
    batt:
      title: 'Battery'
      unit: 'V'
      scale: 3

  feed: 'rf12.packet'

  decode: (raw, cb) ->
    cb
      tag: "HWTANK-#{raw[1]}"
      temp: raw.readUInt16LE(2, true)
      batt: raw.readUInt16LE(6, true)

    if raw[1] == 1
      cb
        tag: "HWTANKLEAK"
        adc: raw.readUInt16LE(4, true)
        batt: raw.readUInt16LE(6, true)