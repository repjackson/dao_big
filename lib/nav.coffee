if Meteor.isClient
    Template.nav.onCreated ->
        Session.setDefault('is_global_searching')
        @autorun => Meteor.subscribe 'me'
        @autorun => Meteor.subscribe 'current_group'
        # @autorun => Meteor.subscribe 'my_cart'
        # @autorun => Meteor.subscribe 'my_unread_messages'
        # @autorun => Meteor.subscribe 'global_stats'
        # @autorun => Meteor.subscribe 'my_cart_order'
        # @autorun => Meteor.subscribe 'my_cart_products'

    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.menu .item')
                .popup()
            $('.ui.left.sidebar')
                .sidebar({
                    context: $('.bottom.segment')
                    transition:'push'
                    mobileTransition:'scale'
                    exclusive:true
                    duration:200
                    scrollLock:true
                })
                .sidebar('attach events', '.toggle_leftbar')
        , 2000
        Meteor.setTimeout ->
            $('.ui.rightbar')
                .sidebar({
                    context: $('.bottom.segment')
                    transition:'push'
                    mobileTransition:'scale'
                    exclusive:true
                    duration:200
                    scrollLock:true
                })
                .sidebar('attach events', '.toggle_rightbar')
        , 2000
        # Meteor.setTimeout ->
        #     $('.ui.topbar.sidebar')
        #         .sidebar({
        #             context: $('.bottom.segment')
        #             transition:'scale'
        #             mobileTransition:'scale'
        #             exclusive:true
        #             duration:200
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_topbar')
        # , 2000
        # Meteor.setTimeout ->
        #     $('.ui.secnav.sidebar')
        #         .sidebar({
        #             context: $('.bottom.segment')
        #             transition:'scale'
        #             mobileTransition:'scale'
        #             exclusive:true
        #             duration:200
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_leftbar')
        # , 2000
        # Meteor.setTimeout ->
        #     $('.ui.sidebar.cartbar')
        #         .sidebar({
        #             context: $('.bottom.segment')
        #             transition:'scale'
        #             mobileTransition:'scale'
        #             exclusive:true
        #             duration:200
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_cartbar')
        # , 3000
        # Meteor.setTimeout ->
        #     $('.ui.sidebar.walletbar')
        #         .sidebar({
        #             context: $('.bottom.segment')
        #             transition:''
        #             mobileTransition:'scale'
        #             exclusive:true
        #             duration:200
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_walletbar')
        # , 2000
    
    Template.right_sidebar.events
        'click .logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'
                
    
    
    Template.nav.helpers
        current_search: ->
            Session.get('global_search')
        
    Template.nav.events
        'keyup .global_search': _.throttle((e,t)->
            # console.log Router.current().route.getName()
            # current_name = Router.current().route.getName()
            # $(e.currentTarget).closest('.input').transition('pulse', 100)

            # unless current_name is 'products'
            Router.go '/search'
            query = $('.global_search').val()
            Session.set('global_search', query)
            # console.log Session.get('product_query')
            if e.key == "Escape"
                Session.set('global_search', null)
                
            if e.which is 13
                search = $('.global_search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('.global_search').val('')
                    Session.set('global_search', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
            else if e.which is 27
                $('.global_search').val('')
                $('.global_search').blur()
                Session.set('is_global_searching', false)
                Session.set('global_search', null)
                    
        , 500)
    
        # 'click .alerts': ->
        #     Session.set('viewing_alerts', !Session.get('viewing_alerts'))
            
        # 'click .toggle_admin': ->
        #     if 'admin' in Meteor.user().roles
        #         Meteor.users.update Meteor.userId(),
        #             $pull:'roles':'admin'
        #     else
        #         Meteor.users.update Meteor.userId(),
        #             $addToSet:'roles':'admin'
        # 'click .toggle_dev': ->
        #     if 'dev' in Meteor.user().roles
        #         Meteor.users.update Meteor.userId(),
        #             $pull:'roles':'dev'
        #     else
        #         Meteor.users.update Meteor.userId(),
        #             $addToSet:'roles':'dev'
        # 'click .view_profile': ->
        #     Meteor.call 'calc_user_points', Meteor.userId(), ->
            
        'click .init_global_search': -> 
            Session.set('is_global_searching', true)
            Meteor.setTimeout =>
                $('.global_search').focus()
            , 500
        'click .clear_search': -> 
            $('.global_search').val('')
            Session.set('is_global_searching', false)
            Session.set('global_search', null)
    
    # Template.topbar.onCreated ->
    #     @autorun => Meteor.subscribe 'my_received_messages'
    #     @autorun => Meteor.subscribe 'my_sent_messages'
    
    Template.nav.helpers
        search_value: ->
            Session.get('global_search')
        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'thing'
                status:'cart'
                _author_id:Meteor.userId()
            }).count()
        cart_items: ->
            # co = 
            #     Docs.findOne 
            #         model:'order'
            #         status:'cart'
            #         _author_id:Meteor.userId()
            # if co 
            Docs.find 
                model:'thing'
                _author_id: Meteor.userId()
                # order_id:co._id
                status:'cart'
                
        alert_toggle_class: ->
            if Session.get('viewing_alerts') then 'active' else ''
        # unread_count: ->
        #     Docs.find( 
        #         model:'message'
        #         recipient_id:Meteor.userId()
        #         read_ids:$nin:[Meteor.userId()]
        #     ).count()
    # Template.topbar.helpers
    #     recent_alerts: ->
    #         Docs.find 
    #             model:'message'
    #             recipient_id:Meteor.userId()
    #             read_ids:$nin:[Meteor.userId()]
    #         , sort:_timestamp:-1
            
    # Template.recent_alert.events
    #     'click .mark_read': (e,t)->
    #         # console.log @
    #         # console.log $(e.currentTarget).closest('.alert')
    #         # $(e.currentTarget).closest('.alert').transition('slide left')
    #         Meteor.call 'mark_read', @_id, ->
                
    #         # Meteor.setTimeout ->
    #         # , 500
         
         
            
    # Template.topbar.events
    #     'click .close_topbar': ->
    #         Session.set('viewing_alerts', false)
    
            
            
    Template.left_sidebar.events
        # 'click .toggle_leftbar': ->
        #     $('.ui.sidebar')
        #         .sidebar('setting', 'transition', 'push')
        #         .sidebar('toggle')
        'click .toggle_admin': ->
            if 'admin' in Meteor.user().roles
                Meteor.users.update Meteor.userId(),
                    $pull:'roles':'admin'
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:'roles':'admin'
        'click .toggle_dev': ->
            if 'dev' in Meteor.user().roles
                Meteor.users.update Meteor.userId(),
                    $pull:'roles':'dev'
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:'roles':'dev'
    # Template.nav.events
    #     'mouseenter .item': (e,t)-> $(e.currentTarget).closest('.item').transition('pulse', '1000')
    # Template.left_sidebar.events
    #     'mouseenter .item': (e,t)-> $(e.currentTarget).closest('.item').transition('pulse', '1000')
    # Template.right_sidebar.events
    #     'mouseenter .item': (e,t)-> $(e.currentTarget).closest('.item').transition('pulse', '1000')
    # Template.secnav.events
    #     'mouseenter .item': (e,t)-> $(e.currentTarget).closest('.item').transition('pulse', '1000')
        # 'click .menu_dropdown': ->
            # $('.menu_dropdown').dropdown(
                # on:'hover'
            # )

        # 'click #logout': ->
        #     Session.set 'logging_out', true
        #     Meteor.logout ->
        #         Session.set 'logging_out', false
        #         Router.go '/'


if Meteor.isServer
    Meteor.publish 'current_group', ->
        if Meteor.user()
            Docs.find
                model:'group'
                _id:Meteor.user().current_group_id