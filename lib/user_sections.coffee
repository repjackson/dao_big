if Meteor.isClient
    Template.user_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'user_upcoming_reservations', Router.current().params.username
    Template.user_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'user_upcoming_reservations', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_handling', Router.current().params.username
        @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
    Template.user_dashboard.helpers
        current_reservations: ->
            Docs.find
                model:'reservation'
                user_username:Router.current().params.username
        upcoming_reservations: ->
            Docs.find
                model:'reservation'
                user_username:Router.current().params.username
        current_handling_rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'rental'
                handler_username:current_user.username
        current_interest_rate: ->
            interest_rate = 0
            if Meteor.user().handling_active
                current_user = Meteor.users.findOne username:Router.current().params.username
                handling_rentals = Docs.find(
                    model:'rental'
                    handler_username:current_user.username
                ).fetch()
                for handling in handling_rentals
                    interest_rate += handling.hourly_dollars*.1
            interest_rate.toFixed(2)


    Template.user_dashboard.events
        'click .recalc_wage_stats': (e,t)->
            Meteor.call 'recalc_wage_stats', Router.current().params.username
