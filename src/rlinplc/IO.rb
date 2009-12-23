require 'singleton'
require 'fileutils'
require 'yaml'

class TOutput

   attr_reader :mainlogger, :outputlogger, :file, :config, :devices, :pi
   include Logging
   def initialize(logfile=nil)
      @file = logfile
      @mainlogger = Log.instance
      @config = RlinConfig.instance
      @devices = Array.new
      @pi = ProcessImage.instance
      @config.variables.each do |h|
         if h['unit'].include? "Output"
	    v = Hash.new
	    v[h['unit'].split("__")[1]] = h['id']
	    @devices << v
	 end
      end
      @outputlogger = Logger.new(@file)
      infolog( "Output Initialization finished")
   end

   def devicelog(message, device = nil)
      @outputlogger.info(device) { message }
   end

   def output
      @devices.each do |h|
         h.each do |key,value|
	    value.each do |var|
	    v = @pi.ioget(var)
	    devicelog(v.id + ":" + v.value.to_s, key)
            end
         end
      end
   end
end

class TInput
   include Logging
   attr_reader :mainlogger,  :file, :input, :devices, :pi
   def initialize(inputfile=nil)
      @file = inputfile
      @mainlogger = Log.instance
      @input = YAML::load(IO.read(@file))
      @config = RlinConfig.instance
      @devices = Array.new
      @pi = ProcessImage.instance
      @config.variables.each do |h|
         if h['unit'].include? "Input"
	    v = Hash.new
	    v[h['unit'].split("__")[1]] = h['id']
	    @devices << v
	 end
      end

      infolog( "Initialization finished")
   end

   def buttonPressed
      if @input.first['time'] > 0
        @input.first['time'] = @input.first['time'] - 1
	processing = @input.first
      else
        processing = @input.slice!(0)
      end
      if processing['action'] == "press"
#         debuglog "press action"
         processing['parameter']
      elsif processing['action'] == "release"
 #        debuglog "release action"
 #        debuglog "!" + processing['parameter']
	 "!" + processing['parameter']
      else
         nil
      end
   end

   def input
	   button = buttonPressed()
	   if button != nil and button[0] != 33
             #testvar = @pi.ioget(button)
	     #debuglog "testvar is a #{testvar.class}"
	     if @pi.ioget(button).class != Array and @pi.ioget(button).value != true
	       debuglog "button #{button} pressed"
	          @pi.iotoggle(button)
#	   elsif
	     end
	   elsif button != nil and button[0] == 33
	     #debuglog "release action"
	     button.delete! "\!"
#	     debuglog(button)
	     if @pi.ioget(button).class != Array and @pi.ioget(button).value != false
	       debuglog "button #{button} released"
	       @pi.iotoggle(button)
	     end
	   end
   end

end

class IOManager
   include Singleton
   include Logging
	attr_reader :input, :output, :mainlogger, :button, :pi


   def initialize
      config = RlinConfig.instance 
      @pi = ProcessImage.instance
      @mainlogger = Log.instance
#         if config.output['plugin'] == "txtfile"
	 @output = Plugin.registered_plugins[config.output['plugin']]
         @output.configure(config.output['parameter'])
#	    @output = TOutput.new(config.output['parameter'])
#	 end
#	 if config.input['plugin'] == "txtfile"
#	    @input = TInput.new(config.input['parameter'])
#	 end
         @input = Plugin.registered_plugins[config.input['plugin']]
         @input.configure(config.input['parameter'])

   end


   def doInput
       @input.input 
  end

  def doOutput
     @output.output
  end
end

