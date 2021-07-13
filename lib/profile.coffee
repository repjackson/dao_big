if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/requests', (->
        @layout 'user_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:username/orders', (->
        @layout 'user_layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/friends', (->
        @layout 'user_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/sent', (->
        @layout 'user_layout'
        @render 'user_sent'
        ), name:'user_sent'
    Router.route '/user/:username/groups', (->
        @layout 'user_layout'
        @render 'user_groups'
        ), name:'user_groups'
    Router.route '/user/:username/chat', (->
        @layout 'user_layout'
        @render 'user_chat'
        ), name:'user_chat'
    Router.route '/user/:username/scheduling', (->
        @layout 'user_layout'
        @render 'user_scheduling'
        ), name:'user_scheduling'
    Router.route '/user/:username/roles', (->
        @layout 'user_layout'
        @render 'user_roles'
        ), name:'user_roles'
    Router.route '/user/:username/stats', (->
        @layout 'user_layout'
        @render 'user_stats'
        ), name:'user_stats'



    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_groups', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_friends', Router.current().params.username

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

        
    Template.user_friends.events    
        'keyup .add_friend_by_username': (e,t)->
            if e.which is '13'
                val = $('.add_friend_by_username').va()
                Meteor.call 'search_by_username', (val, err, res)->
                    console.log res
                    
            
    Template.user_friends.helpers
        user_friends: ->
            
            Meteor.users.findOne username:Router.current().params.username
    Template.user_layout.helpers
        user_from_username_param: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.user_layout.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            # Router.go '/login'
            Meteor.logout()
            
            
    Router.route '/user/:username/edit', -> @render 'user_edit'

    Template.user_edit.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username

    Template.user_edit.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        
        
    Template.friend_button.events
        'click .friend': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    friend_ids:current_user._id
                    
        'click .unfriend': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update Meteor.userId(),
                $pull:
                    friend_ids:current_user._id
                    
    Template.friend_button.helpers
        is_friend: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.user() and Meteor.user().friend_ids and current_user._id in Meteor.user().friend_ids
            
            
            
            
            
    
    Template.user_timeclock.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', Router.current().params.username, 'time_session', ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username

    # Template.user_timeclock.events
    #     'click .clock_in':->
    #         Meteor.users.update Meteor.userId(),
    #             $set:
    #                 clocked_in:true
            
            
    #     'click .clock_out':->
    #         Meteor.users.update Meteor.userId(),
    #             $set:
    #                 clocked_in:false
            
            
            
            
    # Template.user_timeclock.helpers
    #     time_sessions: ->
    #         Docs.find 
    #             model:'time_session'
                
                
                
if Meteor.isServer
    Meteor.publish 'user_friends', (username)->
        user = Meteor.users.findOne username:username
        Meteor.users.find
            _id: $in: user.friend_ids
            
    Meteor.publish 'user_model_docs', (username,model)->
        Docs.find 
            model:model
            _author_username:username
            
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'group'
            _id:$in:user.membership_group_ids
            
    Meteor.methods 
        search_by_username: (username)->
            found = Meteor.users.findOne 
                username:username