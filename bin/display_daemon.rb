require_relative '../lib/display'

require 'eventmachine'

module DIDV
  #modulo que server de servidor para daemon central enviar dados que serão enviados para a linha braile
  module DisplayDaemon

    def post_init
      @display = Display.new
      send_data 'waiting'
    end

    def receive_data(input)
      @display.send_data(input) if @display.complete_line?(input)
      @display.send_with_blink(input) if @display.blink?(input)
      send_data 'waiting'
    end

  end
end

EventMachine.run do
  EventMachine.start_server '127.0.0.1',9002,DIDV::DisplayDaemon
end
