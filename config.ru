require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/MusicOrRiot.db")

class Party
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
	property :admin, Integer, :required => true

	has n, :users
	has n, :songs

	belongs_to :current_song, 'Song', :required => false
end

class Song
	include DataMapper::Resource
	property :id, Serial

	has n, :votes, 'SongVotes'
	
	belongs_to :party
	belongs_to :song_choice
end

class SongChoice
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :unique_index => :song, :required => true
	property :artist, String, :unique_index => :song, :required => true
	property :album, String, :unique_index => :song, :required => true
	property :song_path, String, :required => true

	has n, :songs
end

class SongVotes
	include DataMapper::Resource
	property :id, Serial
	property :score, Integer, :required => true, :default => 0

	belongs_to :user
	belongs_to :song
end

class User
	include DataMapper::Resource
	property :id, Serial
	property :session_identifier, String

	has n, :votes, 'SongVotes'

	belongs_to :party
end

DataMapper.finalize.auto_upgrade!

enable :sessions

before do
	if session[:session_identifier]
		@user = User.first(:session_identifier => session[:session_identifier])
	else
		@user = User.create(:session_identifier => SecureRandom.hex(32))
	end
end

get '/' do
	erb :home
end

run  Sinatra::Application