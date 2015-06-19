# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or create!d alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

user = User.create!(email: 'edguo98@gmail.com', password: '123456')

Team.create!(name: 'F.C. Barcelona',    user: user)
Team.create!(name: 'Real Madrid',       user: user)
Team.create!(name: 'Juventus',          user: user)
Team.create!(name: 'Chelsea',           user: user)
Team.create!(name: 'Manchester United', user: user)
Team.create!(name: 'Manchester City',   user: user)
Team.create!(name: 'Liverpool',         user: user)
Team.create!(name: 'Athletico Madrid',  user: user)
Team.create!(name: 'Steve\'s Red Army', user: user)

field = Field.create!(name: 'Spain', location: '123 Fake Street', user: user)
Timeslot.create!(start_at: 'September 12, 2015  8:00 PM' , field: field)
Timeslot.create!(start_at: 'September 16, 2015  1:00 PM' , field: field)
Timeslot.create!(start_at: 'September 25, 2015  1:00 PM' , field: field)

field = Field.create!(name: 'Portugal', location: '70 Migration Street', user: user)
Timeslot.create!(start_at: 'September 12, 2015 10:00 AM' , field: field)
Timeslot.create!(start_at: 'September 20, 2015  2:00 PM' , field: field)
Timeslot.create!(start_at: 'September 24, 2015  2:00 PM' , field: field)

field = Field.create!(name: 'Red Square', location: '100 Communist Steve Road', user: user)
Timeslot.create!(start_at: 'September 21, 2015 10:00 AM' , field: field)
Timeslot.create!(start_at: 'October 29, 2015  2:00 PM'   , field: field)
Timeslot.create!(start_at: 'October 21, 2015 10:00 AM'   , field: field)
