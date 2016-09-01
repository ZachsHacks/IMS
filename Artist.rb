require 'minitest/autorun'
require 'minitest/spec'


class Artist

    attr_accessor :title
    attr_accessor :list_of_tracks
    attr_accessor :initials

    def initialize(title)
        @title = title
        @list_of_tracks = Array.new
        if @title.include? " "
            x = @title.split(" ")
            initials = x[0][0]
            for index in 1..x.length-1 do
                initials = initials << x[index][0]
            end
            @initials = initials
        else
            @initials = @title[0]
        end
    end

    def add_track(track)
        @list_of_tracks.push(track)
    end

    def countTracks
        return @list_of_tracks.length
    end

    def print_tracks
        print "\n"
        puts "Title of artist: #{@title}"
        if @list_of_tracks.length == 0
            puts "This artist has no tracks yet"
        else
            for x in 0..@list_of_tracks.length-1 do
                print "\n"
                print "Track #{x+1}: "
                puts @list_of_tracks[x].to_s
                print "\n"
            end
        end
    end

    def getInitials
        return @initials
    end

    def getTitle
        return @title
    end
end

# describe "Test1" do
#     it "Prints correctly"  do
#         artist = Artist.new("zach weiss")
#         artist.add_track(Track.new("hello1", "zw"))
#         artist.add_track(Track.new("hello2", "zw"))
#         artist.add_track(Track.new("hello3", "zw"))
#         artist.print_tracks
#     end
# end

# describe "Test2" do
#     it "Plays correctly"  do
#         artist = Artist.new("gaby weiss")
#         artist.add_track(Track.new("hello1", "zw"))
#         artist.add_track(Track.new("hello2", "zw"))
#         artist.add_track(Track.new("hello3", "zw"))
#         artist.list_of_tracks[0].play_track
#         artist.list_of_tracks[0].play_track
#          artist.print_tracks
#     end
# end
