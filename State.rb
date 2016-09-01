require 'pstore'
require_relative 'track'
require_relative 'artist'
require 'minitest/autorun'
require 'minitest/spec'

class State

    attr_accessor :store
    attr_accessor :data

    def initialize
        @store = PStore.new('store.pstore')

        # Load data from the store.
        @data = @store.transaction { @store[:data] }
        # We could also use store.fetch, which does the same as Hash#fetch:
        # Return the value if it exists, otherwise return the default value.
        # data = store.transaction { store.fetch(:data, 'default value') }
    end

    def save_to_disk(aHash, tHash, index)
        @store.transaction do
            # Save the data to the store.
            @store[:artist] = aHash
            @store[:track] = tHash
            @store[:index] = index
            # Oh wait, let's check something first, and if it's
            # not what we expect, abort the transaction and don't
            # write anything to the store.
            @store.commit
            # Another option is to commit early, which also returns
            # from the transaction, but writes what you have done
            # so far. In this case, store[:data] would be written
            # but store[:last_run] would not

            # Save the current time so next time
            # you know when this was last run.
            @store[:last_run] = Time.now

        end
    end

    def load_artist
        @store.transaction do
            @store[:artist]
        end
        # @data[:artist]
    end

    def load_track
        @store.transaction do
            @store[:track]
        end
    end

    def load_index
        @store.transaction do
            @store[:index]
        end
    end

    def empty_file?
        @store.transaction do
            !@store.root?(:artist)
        end
    end

    def clear_storage
        @store.transaction do
            @store.delete(:artist)
            @store.delete(:track)
            @store.delete(:index)
            @store.commit
        end
    end
end

#unit tests
# state = State.new
# # artistHash = {}
# # artist = Artist.new("zach weiss")
# # artist.add_track(Track.new("hello1", "zw"))
# # artist.add_track(Track.new("hello2", "zw"))
# # artist.add_track(Track.new("hello3", "zw"))
# # artistHash.store("zw", artist)
# # artist2 = Artist.new("gaby schwartz")
# # artist.add_track(Track.new("happy1", "gs"))
# # artist.add_track(Track.new("happy2", "gs"))
# # artist.add_track(Track.new("happy3", "gs"))
# # artistHash.store("gs", artist2)
# # puts @artistHash
# # state.save_to_disk(artistHash, nil, nil)
# artistHash = state.load_artist
# puts "TEST: #{artistHash}"
