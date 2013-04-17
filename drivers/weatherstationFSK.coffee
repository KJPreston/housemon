module.exports =

  announcer: 100

  descriptions:
    ['DCF77', 'WS4000', 'WS3000']

  DCF77:
    date:
      title: 'Date'
    tod:
      title: 'Time'
    dst:
      title: 'Summer'

  WS4000:
    seq:
      title: 'Sequence number'
    protocol:
      title: 'Protocol'
    mt:
      title: 'Message type'
    StId:
      title: 'Station ID'
    T:
      title: 'Temperature'
      unit: '`C'
      min: -99
      max: 99
    Rh:
      title: 'Humidity'
      unit: '%'
      min: 0
      max: 100
    Ws:
      title: 'Wind speed'
      unit: 'm/s'
      min: 0
    Wg:
      title: 'Wind gust speed'
      unit: 'm/s'
      min: 0
    Wdir:
      title: 'Wind direction'
    Rain:
      title: 'Rain cummulative'
      unit: 'mm'
      min: 0

  WS3000:
    seq:
      title: 'Sequence number'
    protocol:
      title: 'Protocol'
    mt:
      title: 'Message type'
    StId:
      title: 'Station ID'
    T:
      title: 'Temperature'
      unit: '`C'
      min: -99
      max: 99
    Rh:
      title: 'Humidity'
      unit: '%'
      min: 0
      max: 100
    Ws:
      title: 'Wind speed'
      unit: 'm/s'
      min: 0
    Wg:
      title: 'Wind gust speed'
      unit: 'm/s'
      min: 0
    Rain:
      title: 'Rain cummulative'
      unit: 'mm'
      min: 0


  feed: 'rf12.packet'

  decode: (raw, cb) ->
    seq = raw[1]
    type = raw[2]
    #console.log(raw)
    
    size = raw[3]
    name = fskDecoderType[type]
    offset = 4
    seg = raw.slice(offset, offset+size)
    if fskDecoders[name]
      fskDecoders[name] seg, seq, cb
    else
      cb
        tag: name
        hex: seg.toString('hex').toUpperCase()

fskDecoderType =  { 40: 'ws_sensor', 41: 'dcf', 42: 'ws_sensor' }

fskDecoders =

  dcf: (tbuf, seq, cb) ->
    dt = new Date(2000 + BCD2bin(tbuf[5]), (BCD2bin(tbuf[6] & 0x1F))-1, BCD2bin(tbuf[7]), BCD2bin(tbuf[2] & 0x3F), BCD2bin(tbuf[3]), BCD2bin(tbuf[4]), 0)
    cb
      tag: 'DCF77'
      date: dt.toDateString()
      tod: dt.toTimeString()
      dst: '?'
      seq: seq
    
  ws_sensor: (raw, seq, cb) ->
    mt = raw[0] >> 4
    stid = (raw[0] & 0x0F) << 4 | raw[1] >> 4
    if mt == 0xB or mt == 0x6
      dt = new Date(2000+BCD2bin(raw[5]), BCD2bin(raw[6] & 0x1F)-1, BCD2bin(raw[7]), BCD2bin(raw[2] & 0x3F), BCD2bin(raw[3]), BCD2bin(raw[4]), 0)
      cb
        tag: "DCF77-#{stid}"
        date: dt.toDateString()
        tod: dt.toTimeString()
        dst: '?'
        seq: seq
    else if mt == 0xA or mt == 0x5
      compass = ["N  ", "NNE", "NE ", "ENE", "E  ", "ESE", "SE ", "SSE", "S  ", "SSW", "SW ", "WSW", "W  ", "WNW", "NW ", "NNW"]
      sign = (raw[1] >> 3) & 1
      temp = ((raw[1] & 0x07) << 8) | raw[2]
      if (sign)
        temp = (~temp)+sign
      info =
        seq: seq
        StId: stid
        T: Math.round(1000 * temp * 0.1)/1000
        Rh: raw[3]
        Ws: Math.round(1000 * raw[4] * 0.34)/1000
        Wg: Math.round(1000 * raw[5] * 0.34)/1000
        Rain: Math.round(1000 * (((raw[6] & 0x0F) << 8) | raw[7]) * 0.3)/1000
      if mt==0xA
        info.Wdir = compass[raw[8] & 0x0F]
        info.tag = "WS4000-#{stid}"
      else
        info.tag = "WS3000-#{stid}"
      #console.log(info)

      cb info
    else
      cb
        tag: name
        hex: seg.toString('hex').toUpperCase()
 
BCD2bin = (BCD) ->
  10 * (BCD >> 4 & 0xF) + (BCD & 0xF)
     