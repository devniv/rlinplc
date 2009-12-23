require "rlinplc/Log"
require "rlinplc/Config"
require "rlinplc/Hal"
require "rlinplc/IO"
require "rlinplc/Plugin"

# require "rlinplc/Player"

class TestHAL
  include Logging
  def run
  pi = ProcessImage.instance
  config = RlinConfig.instance
  io = IOManager.instance
  log = Log.instance
  @mainlogger = Log.instance
  lang = Plugin.registered_plugins["#{config.langparams}_#{config.lang}"]
#	debuglog @lang.instance_variable_get(:@mainlogger)
  lang.configure()
#debuglog lang.instance_variable_get(:@mainlogger)
#  player = Player.new

  # run every second
    while(true)
      # Input
      io.doInput()
#      pi.printStatus()
      # Calculate and Manipulate
      lang.run()
      # Output
 #     pi.printStatus()
      io.doOutput()
      sleep(1)
    end
  end
end

test = TestHAL.new
test.run
