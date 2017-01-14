ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Genre < ActiveRecord::Base
	validates :name, uniqueness: true
end
