require "rlinplc/Log"
require "rlinplc/Config"
require "rlinplc/Hal"
require "rlinplc/IO"
require "rlinplc/Plugin"


class TestHAL
  include Logging
  def run
  pi = ProcessImage.instance
  config = RlinConfig.instance
  io = IOManager.instance
  log = Log.instance
  @mainlogger = Log.instance
  lang = Plugin.registered_plugins["#{config.langparams}_#{config.lang}"]
  lang.configure()

  # run every second
    while(true)
      # Input
      io.doInput()
      # Calculate and Manipulate
      lang.run()
      # Output
      io.doOutput()
      sleep(1)
    end
  end
end

test = TestHAL.new
test.run
