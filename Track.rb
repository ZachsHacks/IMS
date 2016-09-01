require 'minitest/autorun'
require 'minitest/spec'

class Track
    attr_accessor :name
    attr_accessor :artist
    attr_accessor :times_played
    attr_accessor :current

    def initialize(name, artist)
        @name=name
        @artist=artist
        @times_played = 0
        @current = false
    end

    def play_track
        @times_played +=1
        @current = true
    end

    def stop_track
        @current = false
    end

    def is_Playing?
        return @current
    end

    def get_artist
        "#{@artist}"
    end

    def to_s
        "#{@name}"  #String interpilation
    end

end

#unit tests

describe "Test1" do
    it "Works correctly"  do
        track = Track.new("Test", "zw")
        track.play_track
        puts track.get_artist
        puts track.to_s
    end
end
