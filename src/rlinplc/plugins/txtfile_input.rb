### this under PLUGIN_DIR/
Plugin.define "txtfile_input" do
  author "Nicolas Vilz"
  version "1.0.0"
  unit "Input"
  description "I/O Plugin for Input from a textfile"
 
   def configure(inputfile=nil)
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
         processing['parameter']
      elsif processing['action'] == "release"
	 "!" + processing['parameter']
      else
         nil
      end
   end

   def input
	   button = buttonPressed()
	   if button != nil and button[0] != 33
	     if @pi.ioget(button).class != Array and @pi.ioget(button).value != true
	       debuglog "button #{button} pressed"
	          @pi.iotoggle(button)
	     end
	   elsif button != nil and button[0] == 33
	     button.delete! "\!"
	     if @pi.ioget(button).class != Array and @pi.ioget(button).value != false
	       debuglog "button #{button} released"
	       @pi.iotoggle(button)
	     end
	   end
   end

end
####

