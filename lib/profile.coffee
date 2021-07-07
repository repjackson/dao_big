if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/requests', (->
        @layout 'user_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:username/posts', (->
        @layout 'user_layout'
        @render 'user_posts'
        ), name:'user_posts'
    Router.route '/user/:username/sent', (->
        @layout 'user_layout'
        @render 'user_sent'
        ), name:'user_sent'
    Router.route '/user/:username/groups', (->
        @layout 'user_layout'
        @render 'user_groups'
        ), name:'user_groups'
    Router.route '/user/:username/timeclock', (->
        @layout 'user_layout'
        @render 'user_timeclock'
        ), name:'user_timeclock'
    Router.route '/user/:username/payroll', (->
        @layout 'user_layout'
        @render 'user_payroll'
        ), name:'user_payroll'
    Router.route '/user/:username/scheduling', (->
        @layout 'user_layout'
        @render 'user_scheduling'
        ), name:'user_scheduling'
    Router.route '/user/:username/roles', (->
        @layout 'user_layout'
        @render 'user_roles'
        ), name:'user_roles'



    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_groups', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

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

    Template.user_timeclock.events
        'click .clock_in':->
            Meteor.users.update Meteor.userId(),
                $set:
                    clocked_in:true
            
            
        'click .clock_out':->
            Meteor.users.update Meteor.userId(),
                $set:
                    clocked_in:false
            
            
            
            
    Template.user_timeclock.helpers
        time_sessions: ->
            Docs.find 
                model:'time_session'
                
                
                
if Meteor.isServer
    Meteor.publish 'user_model_docs', (username,model)->
        Docs.find 
            model:model
            _author_username:username
            
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'group'
            _id:$in:user.membership_group_ids
            
            