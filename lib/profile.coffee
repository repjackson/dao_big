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
    Router.route '/user/:username/menu', (->
        @layout 'user_layout'
        @render 'user_menu'
        ), name:'user_menu'



    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
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