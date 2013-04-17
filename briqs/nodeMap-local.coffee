# Static node map and other data. This information is temporary, until a real
# admin/config interface is implemented on the client side. The information in
# here reflects the settings used at JeeLabs, but is also used by the "replay"
# briq, which currently works off one of the JeeLabs log files.
#
# This file is not treated as briq because it does not export an 'info' entry.
#
# To add your own settings: do *NOT* edit this file, but create a new one next
# to it called "nodeMap-local.coffee". For example, if you use group 212:
#
#   exports.rf12nodes = 
#     212:
#       1: 'roomNode'
#       2: ...etc
#
# The settings in the local file will be merged (and can override) the settings
# in this file. If you override settings, the "replay" briq may no longer work.

fs = require 'fs'

# this is still used for parsing logs which do not include announcer packets
# TODO: needs to be time-dependent, since the config can change over time
exports.rf12nodes =
  212:
    18: 'roomNode'
    21: 'hahNodeV1'
    22: 'hahNodeV1'
    23: 'roomNode'
    24: 'hahNodeV1'
    25: 'roomNode'
#tankNode displays as HWTANKxxxxxxx
    8:  'tankNode'
    7:  'boilerNode'
    39: 'boilerNode'
    15: 'weatherstationFSK'
    14: 'bmp085'

# devices are mapped to RF12 configs, since that is not present in log files
# TODO: same time-dependent comment as above, this mapping is not fixed
# this section is only used by the 'rf12-replay' briq
exports.rf12devices =
  'usb-A40117UK':
    recvid: 1
    group: 5
    band: 868

# static data, used for local testing and for replay of the JeeLabs data
# these map incoming sensor identifiers to locations in the house
exports.locations =
  'RF12:212:18': title: 'Devon Bedroom'
  'RF12:212:21': title: 'Kitchen'
  'RF12:212:22': title: 'Lobby'
  'RF12:212:23': title: 'LivingRoom'
  'RF12:212:24': title: 'Conservatory'
  'RF12:212:25': title: 'Landing'
  'HWTANK-1': title: 'HWTankTemp Top'
  'HWTANK-2': title: 'HWTankTemp Tap'
  'HWTANK-3': title: 'HWTankTemp Bottom'
  'HWTANKLEAK': title: 'HWTankLeakSensor'
  'RF12:212:7': title: 'Boiler Controller'
  'RF12:212:39': title: 'Boiler Controller.'
  'WS4000-87': title: 'WH1080 Weather Station - 3'
  'DCF77-87': title: 'WH1080 DCF77 Clock - 3'
  'RF12:212:14': title: 'BMP085 Weather Station - 3'

