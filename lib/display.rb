#simplest ruby program to read from PIC USBserial,
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require "serialport"
require "pry"
require "timeout"

module DIDV

  #Classe Display, responsavel por enviar dados a linha braile
  class Display

    attr_accessor :sp, :send_error, :last_sent_packet

    # Although the serial device can be customized, we suggest it
    # to be 'locked' to /dev/didv-display using a custom udev rule
    #@param serial_device[string] por padrão   usa "/dev/didv-display" caso nenhum outro caminho seja especificado
    def initialize (serial_device = "/dev/didv-display")

      @sp = SerialPort.new(serial_device, 57600, 8, 1, SerialPort::NONE)
    end

    #Envia do dato atráves da porta serial, e salva o ultimo dado enviado, para caso seja necessário tentar novamente
    #@param data[Array] of 12(n) chars
    def send_data data
      puts "Sending '#{data}'..."
      @last_sent_data = data
      data.each { |c| sp.putc c }
      puts "Data sent :'#{data}'"
    end

    #Verifica se o dado entrado é valido, ou seja, é um array de 10 posições
    #@param data[Array] of 10 chars
    def valid?(data)
      data.size == 10
    end

    #recebe dado da porta serial utilizando um timeout, para não ficar esperando eternamente uma respotas
    #@param times[int] Quantidade de dados a serem recebidos, caso não seja especificado verificará até o estouro do timer de segurança
    def get_data_with_timeout times=nil
      begin
        Timeout.timeout(2) { get_data times }
      rescue Timeout::Error
        puts 'Sem mais dados para receber'
      end
    end

    #envia um dado e espera uma reposta de mesmo tamanho do dado enviado
    #@param data[Array] dado a ser enviado
    def send_and_get_data data
      send_data data
      get_data_with_timeout data.size
    end

    #Função que prepara e envia um bloco inteiro de chars para o pic, dividida em duas partes:
    #*Primeira: prepara o dado para ser enviado
    #*Segunda: Envia o dado pela porta serial
    #@param data[Array] de 10 chars que serão enviados para a linha
    def send_hex data
    data = packetize_data data
    send_and_get_data data
  end

    private

    #Recebe um pacote e o coloca no formato correto para o envio de dados(todas as celulas)
    #@param data[Array] of 10 chars
    #@return [Array] An array of 12 positions, where first is '0x40' and the last is '0x41'
    def packetize_data data
      data_to_send = Array.new
      data_to_send[0] = 0x40.chr
      data_to_send[11] = 0x41.chr
      (1..10).each { |i| data_to_send[i] = data[i-1] }
      data_to_send
    end


    #Just gets data, for a secure use, use get_data_with_timeout
    def get_data times=nil
      puts "Getting getting data..."
      if (times)
        times.times { check_data }
      else
        loop { check_data }
      end
    end

    #modify to send data to somewhere that it makes sense
    def foward_data data
      puts "#{data}"
      if (data == 'E')
        send_data @last_sent_data
      elsif (data == 'N')
        puts "erro durante a transmissão"
      end
    end

    #Check if there is any data available, and send it to somewhere (where?)
    def check_data
      foward_data sp.getc
    end

  end
end

# Just for tests
# 0x3f logic high state
# in order to test, set ENV['DIDV'] to "test" by running:
# ~ export DIDV=test

if ENV['DIDV'] == "test"
  puts "stating test"
  serial = DIDV::Display.new
  a = Array.new #test array
  (0..4).each {|data| a[data] = 0x00.chr}
  (5..10).each {|data| a[data]=0x3f.chr}
  a = serial.packetize_data a
  serial.send_and_get_data a
  binding.pry
end
