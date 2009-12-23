## this under PLUGIN_DIR/
class Ptrack
   attr_accessor :title, :interpret, :time

   def initialize(title, interpret, time)
      @title = title
      @interpret = interpret
      @time = time
   end

   def to_s
      @interpret.to_s + " + " + @title.to_s + ":" + @time.to_s
   end
end

class Playlist < Array
end


Plugin.define "player_ruby" do
  name "player_ruby"
  author "Nicolas Vilz"
  version "1.0.0"
  unit "Lang"
  description "MP3-Player App as Fassade for the PLC HAL"

  def configure
    @ppl = 1
    @ptr = 1
    @current_track = nil
    @current_remaining_time = 0.0
    @current_playlist = nil
    @current_mode = 0
    @current_audio_status = false
    @mainlogger = Log.instance 
    @pi = ProcessImage.instance
    @playlists = Array.new
    p = YAML::load(IO.read('playlist.yml'))
    iterator2 = 1
    p.each do |h|
    iterator = 1
      pl = Playlist.new
      h['tracks'].each do |i|
         entry = Hash.new
         entry['no'] = iterator
	 entry['track'] = Ptrack.new(i['title'],i['interpret'],i['time'])
	 pl << entry
      iterator += 1
      end
      ple = Hash.new
      ple['no'] = iterator2
      ple['playlist'] = pl
      @playlists << ple
      iterator2 +=1
    end
    fetch_playlist(@ppl)
    fetch_playlist_item(@ptr)
    load_track(@current_track)
    infolog("Player configuration finished")
  end


  def printPlaylists
     puts @playlists
  end

  def play_track
     @current_audio_status = true
     if @current_remaining_time > 0.0 
        new_remaining_time = (@current_remaining_time * 60 -1)/60
	if new_remaining_time > 0.0
	   @current_remaining_time = new_remaining_time
	else
	   @current_remaining_time = 0.0
	end
     else
        next_track
     end
  end

  def pause_track
     @current_audio_status = false
  end

  def stop_track
     @current_audio_status = false
     load_track(@current_track)
  end

  def next_track
     @ptr += 1
     if @ppl < @playlists.size or @ppl == @playlists_size
        fetch_playlist(@ppl)
        if @ptr < @current_playlist.size 
           fetch_playlist_item(@ptr)
           load_track(@current_track)
        else
           @ppl +=1
           @ptr = 1
           fetch_playlist(@ppl)
           fetch_playlist_item(@ptr)
           load_track(@current_track)
        end
     else 
        @ppl = 1
        @ptr = 1
        fetch_playlist(@ppl)
        fetch_playlist_item(@ptr)
        load_track(@current_track)
     end
  end

  def prev_track
     @ptr -= 1
     if @ppl > 0 
        fetch_playlist(@ppl)
        if @ptr < @current_playlist.size 
           fetch_playlist_item(@ptr)
           load_track(@current_track)
           doOutput()
        else
           @ppl -=1
           fetch_playlist(@ppl)
	   @ptr = @current_playlist.size
           fetch_playlist_item(@ptr)
           load_track(@current_track)
	   doOutput()
        end
     else 
        @ppl = @playlists.size
        fetch_playlist(@ppl)
        @ptr = @current_playlist.size
        fetch_playlist_item(@ptr)
        load_track(@current_track)
        doOutput()
     end
  end

  def fetch_playlist(num)
    @ppl = num
    @playlists.each do |h|
       if h['no'] == @ppl
          @current_playlist = h['playlist']
       end
    end
  end

  def fetch_playlist_item(num)
    @ptr = num
    @current_playlist.each do |h|
       if h['no'] == @ptr
          @current_track = h['track']
       end
    end
  end

  def load_track(track)
    @current_remaining_time = track.time 
  end

  def doOutput
     @pi.langset("remaining_time", @current_remaining_time)
     @pi.langset("playlist", @ppl)
     @pi.langset("track", @ptr)
     @pi.langset("mode", @current_mode)
     @pi.langset("audio_data", @current_audio_status)
  end

  def doInput

  end

  def run
     debuglog("entering run")
     # Eingabe
     if @pi.langget("T_Play").value == true
       @current_mode = 1
       debuglog(@pi.langget("T_Play").to_s)
     end
     if @pi.langget("T_Stop").value == true
       @current_mode = 0
       debuglog(@pi.langget("T_Stop").to_s)
     end
     if @pi.langget("T_Pause").value == true
       @current_mode = 2
       debuglog(@pi.langget("T_Pause").to_s)
     end

     # Verarbeitung
     case @current_mode
       when 0
          stop_track
	  infolog("stopping track")
      when 1
          play_track
	  infolog("continue playing track")
      when 2
          pause_track
	  infolog("pausing track")
     end

     # Ausgabe
    doOutput()
    debuglog("leaving run")
  end
end
