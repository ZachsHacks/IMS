require "byebug"
require_relative 'track'
require_relative 'artist'
require_relative 'state'

class IMS
    attr_accessor :current_state
    attr_accessor :artistHash
    attr_accessor :trackHash
    attr_accessor :current_Track
    attr_accessor :index

    def initialize
        puts "\nWelcome to the Zach's Interactive Music Shell!"
        print "\n"
        puts "Please enter a command to continue: "
        display_help
        @current_state = State.new
        if @current_state.empty_file?
            @artistHash = {}
            @current_Track = nil
            @trackHash = {}
            @index = 0
        else
            @artistHash = @current_state.load_artist
            @current_Track = nil
            @trackHash = @current_state.load_track
            @index = @current_state.load_index
        end
    end

    def run
        while (true)
            puts "Enter 'help' for commands."
            print "> "
            command = gets.chomp
            command = command.split(" ")
            key = command[0]
            key_table = {
                "exit" => "exit_IMS",
                "help" => "display_help",
                "info" => "info(#{command})",
                "add" => "add(#{command})",
                "list" => "list(#{command})",
                "count" => "count(#{command})",
                "play" => "play(#{command})",
                "delete" => "delete",
                "stop" => "stop"
            }
            if key_table.key?(key)
                instance_eval(key_table[key])
            else puts "Invalid command. Please try again"
            end
        end
    end

    def stop
        @index = nil
        puts "Stopped playing track"
    end

    def exit_IMS
        @current_state.save_to_disk(@artistHash, @trackHash, @index)
        puts "You saved your information. See you later!"
        exit!
    end

    def display_help
        puts "'exit' - save state and exit."
        puts "'info' - display a high level summary of the state."
        puts "'info track' - Display info about a certain track by number (e.g. info track 1)"
        puts "'info artist' - Display info about a certain artist, by initials (e.g. info artist zw)"
        puts "'add artist' - add artist by name (e.g. add artist pito salas)"
        puts "'add track' - add track by artist initials (e.g. add track help! by tb)"
        puts "'play track' - Record that an existing track was played at the current time. (e.g. play track 13)"
        puts "'stop music' - Stops track that is currently playing."
        puts "'count tracks' - Display how many tracks are known by a certain artist's initials. (count tracks by jo)"
        puts "'list tracks' - list the tracks played by a certain artist. (list tracks by jo)"
        puts "'list artist' - list of all artists in library"
        puts "(You can also just write 'list tracks' to display all tracks in library.)"
        puts "'delete library' - Delete entire library"
        puts "\n"
    end

    def info(command)
        if command[1] == "track"
            if command.length>2 && (is_number? (command[2])) && command[2].to_i>0
                if  @trackHash.key?(command[2].to_i-1)
                    print "Track: "
                    print @trackHash[command[2].to_i-1].to_s
                    print " by "
                    puts @trackHash[command[2].to_i-1].get_artist
                else "You don't have Track #{command[2]-1} in your library."
                end
            else puts "Error. Please try again. (e.g. info track 1)"
            end
        elsif command[1] == "artist"
            if @artistHash.key?(command[2])
                puts @artistHash[command[2]].print_tracks
            else puts "You don't have #{command[2]} in your library."
            end
        else
            puts "~You have #{@artistHash.size} artists in your library."
            puts "~In total, your library has #{@trackHash.size} songs."
            if @index != nil
                puts "~The current track is #{@trackHash[index].to_s}"
            else puts "No current track is playing"
            end
        end
    end

    def add(command)
        if command[1] == "artist"
            artistTitle = ""
            for x in 2..command.length-1 do
                artistTitle = artistTitle << command[x]
                if x <= command.length-2
                    artistTitle = artistTitle + " "
                end
            end
            currentArtist = Artist.new(artistTitle)
            @artistHash.store(currentArtist.getInitials, currentArtist)
            puts "Artist added!"
        elsif command[1] == "track"
            if command.include?("by") && command[2] != "by"
                trackTitle = ""
                i = 2
                begin
                    trackTitle = trackTitle << command[i]
                    if i < command.length-3
                        trackTitle = trackTitle + " "
                    end
                    i += 1
                end until command[i] == "by"
                currentInitials = command[i+1]
                if @artistHash.key?(currentInitials)
                    @artistHash[currentInitials].add_track(Track.new(trackTitle, currentInitials))
                else
                    currentArtist = Artist.new(currentInitials)
                    @artistHash.store(currentInitials, currentArtist)
                    @artistHash[currentInitials].add_track(Track.new(trackTitle, currentInitials))
                end
                @trackHash.store(@index, Track.new(trackTitle, currentInitials))
                @index+=1
                puts "Track added!"
            else puts "Invalid response, please try again. (e.g. add track party rock by l)"
            end
        end
    end

    def list(command)
        if command[1] == "tracks"
            if command[3] != nil
                puts @artistHash[command[3]].print_tracks
            else
                if @trackHash.size > 0
                    trackAr = @trackHash.to_a
                    for x in 0..trackAr.length-1 do
                        puts "Track #{x+1}: #{trackAr[x][1]}"
                    end
                else
                    puts "There are no tracks yet."
                end
            end
        elsif command[1] =="artists"
            artistAr = @artistHash.to_a
            for x in 0..artistAr.length-1 do
                puts "-#{artistAr[x][1].title}"
            end
            puts "Error. No artist found. When requesting info about an artist, use initials (e.g. ps for pito salas)"
        end
    end

    def count(command)
        if @artistHash.key?(command[3])
            print "Your library has "
            print @artistHash[command[3]].countTracks
            print " tracks by "
            puts @artistHash[command[3]].getTitle
        else
            puts "Sorry, the artist you selected doesn't exist yet in your library yet."
        end
    end

    def delete
        puts "Are you sure you want to delete your entire library?"
        print "> "
        command = gets.chomp
        if command == "yes"
            @current_state.clear_storage
            puts "DELETED ENTIRE LIBRARY"
            puts "Please restart manually to continue..."
            exit!
        end
    end

    def is_number? string
        true if Float(string) rescue false
    end

    def play(command)
        if command.length>2 && (is_number? (command[2]))
            @index = command[2].to_i
            if @trackHash.size>0 && @index<=@trackHash.size
                if @trackHash[@index] != nil && @trackHash[@index].is_Playing?
                    @trackHash[@index].stop_track
                end
                #Play track by number
                print "Now playing: "
                puts @trackHash[@index-1].to_s
                @trackHash[@index-1].play_track
            else puts "Error. No track to play. (Type 'list tracks' to make selection by number)"
            end
        else puts "Error. No track to play. (Type 'list tracks' to make selection by number)"
        end

    end

    i = IMS.new.run
    i.run

end
