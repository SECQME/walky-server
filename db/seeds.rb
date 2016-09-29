# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ReportCategory.create([{name: 'Construction', group_name: 'Hazardous walkways'},
	{name: 'No sidewalks', group_name: 'Hazardous walkways'},
	{name: 'Catcalling', group_name:'Creeps & Harrasers'},
	{name: 'Drunk & Disoderly', group_name:'Creeps & Harrasers'},
	{name: 'Loitering', group_name:'Creeps & Harrasers'},
	{name: 'Gangs', group_name:'Creeps & Harrasers'},
	{name: 'Flashers & indecency', group_name:'Creeps & Harassers'},
	{name: 'Dark unlit streets', group_name: 'Dark unlit streets'},
	{name: 'Fights', group_name: 'Violent assault'},
	{name: 'Gun violence', group_name: 'Violent assault'},
	{name: 'Thief & Robbery', group_name: 'Thief & Robbery'},
	{name: 'Molestation', group_name: 'Sexual Assault'},
	{name: 'Rape', group_name: 'Sexual Assault'},
	{name: 'Groping', group_name: 'Sexual Assault'},
	{name: 'Wild dogs or animals', group_name: 'Wild dogs or animals'},
	{name: 'General map error',group_name: 'Map issues'},
	{name: 'I feel safe here even though you said it wasn\'t',group_name: 'Map issues & problems'},
	{name: 'No walking allowed',group_name: 'Map issues & problems'},
	{name: 'Wrong walking directions',group_name: 'Map issues & problems'},
	{name: 'Others', group_name: 'Others reports'}])
