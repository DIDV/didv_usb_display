#simplest ruby program to read from PIC USBserial,
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require "serialport"
require "pry"
require "timeout"
module DIDV
  class Serial_communication

    attr_accessor :sp, :send_error, :last_sent_packet
    def initialize(baud_rate=57600, data_bits=8, stop_bits=1, parity=SerialPort::NONE)
      port_str = "/dev/ttyACM0"  #may be different for you
      @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    end

    def packetize_data data
      data_to_send = Array.new
      data_to_send[0] = 0x40.chr
      data_to_send[11] = 0x43.chr
      (1..10).each { |i| data_to_send[i] = data[i-1] }
      data_to_send
    end

    def send_data data
      puts "Sending '#{data}'..."
      @last_sent_data = data
      data.each { |c| sp.putc c }
      puts "Data sent :'#{data}'"
    end

    def get_data times=nil
      # this first version just gets data forever
      puts "Getting getting data..."
      if (times)
        times.times { check_data }
      else
        #TODO pensar na recepção
        loop { check_data }
      end
    end

    def get_data_with_timeout times=nil
      require 'timeout'
      begin
        Timeout.timeout(2) do
        get_data times
      end

    rescue Timeout::Error
      puts 'Sem mais dados para receber'
    end

  end

  def send_and_get_data data
    send_data data
    get_data_with_timeout data.size
  end

  def foward_data data
    puts "#{data}" #modify to send data to somewhere that it makes sense
    if (data == 'E')
      send_data @last_sent_data
    elsif (data == 'N')
      puts "erro durante a transmissão"
    end
  end

  def check_data
    foward_data sp.getc
  end

end
#Just for tests
#0x3f nivel logico alto
serial = Serial_communication.new
a = Array.new #test array
(0..4).each {|data| a[data] = 0x00.chr}
(5..10).each {|data| a[data]=0x3f.chr}
a = serial.packetize_data a
serial.send_and_get_data a
binding.pry
end
#binding.pry