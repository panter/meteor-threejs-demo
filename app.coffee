@Collections = {}
@Collections.Players = new Meteor.Collection "Players"


if Meteor.isClient
	Template.app.helpers
		players: -> Collections.Players.find()
