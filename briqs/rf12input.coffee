#rf12input collects input using the following mechanisms
#
#   unix domain sockets
#   *xap (udp)
#   *sockets (tcp)
#   *rest (http)
#
#  It does this by emitting events using a defined naming convention of:
#  rf12.input.<band>.<group> with a single parameter (data) which is understood by rf12demo.9+


net = require('net')
readline  = require('readline')

exports.info =
  name: 'rf12input'
  description: 'Provide RF12 Input'
  menus: [
    title: 'Rf12input'
    controller: 'Rf12inputCtrl'
  ]




state = require '../server/state'

class RF12Input 

  
  constructor: -> 

    @fs = require('fs');

    @TCP_PORT = 3334
    @DOMAIN_SOCK = '/tmp/rf12input.sock'
    @Dserver = {} #domain socket object
    @Tserver = {} #tcp socket object

    try
      @fs.unlinkSync @DOMAIN_SOCK
    catch error
      #just ignore
    finally
      #just continue
   
    console.log "+++++++++++++++++++++++++++++++++++++" 

    #callback = => @send "868","212", "0,0,0,0,0,0,2,0,7s"
    #setInterval callback, 30000
    #callback1 = => @send "868","210", "0,0,0,0,0,0,2,0,7s"
    #setInterval callback1, 15000


    self = @
    #===========================================
    #create a unix domain socket server
    @Dserver = net.createServer (socket) -> 
      socket.on 'connect', (listener) ->
        console.log "Socket client connect"
        self.help socket

      
      rl = readline.createInterface socket, socket


      rl.on 'line', (line) =>
        self.processInput line, socket
       
      socket.on 'end', () -> 
        console.log 'server disconnected'
  
    @Dserver.listen @DOMAIN_SOCK, () ->
      console.log 'server bound: ' + self.DOMAIN_SOCK
    #============================================
 

    #============================================
    #create TCP socket server
    @Tserver = net.createServer (socket) -> 
      socket.on 'connect', (listener) ->
        console.log "Socket client connect"
        self.help socket

      
      rl = readline.createInterface socket, socket


      rl.on 'line', (line) =>
        self.processInput line, socket
       
      socket.on 'end', () -> 
        console.log 'server disconnected'
  
    @Tserver.listen @TCP_PORT, () ->
      console.log 'server bound :' + self.TCP_PORT
    #===============================================

  help: (stream) =>
    stream.write "syntax send <band> <group> <command>\n"
     
  processInput: (line, stream) =>
    console.log 'Processing:' + line
    stream.write 'Processing: ' + line + '\n'
    input = line.split ' ' #action[0] band[1] group[2] command[3]
    for x in [4..input.length]
      input[3]+= ' ' + input[x]

    if (input.length >= 4) && (input[0] == 'send')
      @send input[1], input[2], input[3]
      stream.write 'Sent\n'
    else
      stream.write "do you need syntax help?\n"


  send: (band, group, data) =>
    console.log "########input-" + band + "-" + group + " " + data
    state.emit 'rf12.input.' + band + '.' + group, data


  destroy: => 
    console.log "Destroy - cleaning up rf12input"
    @Dserver.close() 
    @Tserver.close()
    @Dserver.unref()
    @Tserver.unref()


exports.factory = RF12Input

#module.exports = RF12Input


