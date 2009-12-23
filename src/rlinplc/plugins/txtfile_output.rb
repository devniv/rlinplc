### this under PLUGIN_DIR/
Plugin.define "txtfile_output" do
  author "Nicolas Vilz"
  version "1.0.0"
  unit "Output"
  description "I/O output plugin for textfiles"
 
   def configure(outputfile=nil)
      @file = outputfile
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
####

