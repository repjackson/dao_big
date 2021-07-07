@picked_tags = new ReactiveArray []


# Meteor.startup ->
#     Status.setTemplate('semantic_ui')

Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0



$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'


Template.admin_footer.onCreated ->
    @autorun -> Meteor.subscribe 'admin_tasks'
    @autorun -> Meteor.subscribe 'admin_notes'

Template.admin_footer.helpers
    admin_notes: ->
        Docs.find
            model:'note'
            admin:true
            pathname_root: window.location.pathname.split('/')[1]
    admin_tasks: ->
        Docs.find
            model:'task'
            admin:true
            pathname_root: window.location.pathname.split('/')[1]
    is_editing: ->
        Session.equals('editing_id', @_id)
    
Template.admin_footer.events
    'click .toggle_admin_view': -> 
        Session.set('view_admin', !Session.get('view_admin'))
    'click .save': -> Session.set('editing_id', null)
    'click .edit': -> Session.set('editing_id',@_id) 
    'click .delete': -> 
        if confirm "delete #{@title} task?"
            Docs.remove @_id

    'click .add_admin_task': ->
        console.log window.location.pathname.split('/')[1]

        new_id = 
            Docs.insert 
                model:'task'
                admin:true
                pathname_root: window.location.pathname.split('/')[1]
        Session.set('editing_id', new_id)
    'click .add_admin_note': ->
        new_id = 
            Docs.insert 
                model:'note'
                admin:true
                pathname_root: window.location.pathname.split('/')[1]
        Session.set('editing_id', new_id)
        
        
Template.body.events
    'click .zoom_out': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale', 500)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 500)


    "click a:not('.no_blink')": ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.healthclub.events
    # 'click .button': ->
    #     $('.global_container')
    #     .transition('fade out', 5000)
    #     .transition('fade in', 5000)

Template.layout.helpers
    logging_in: -> Meteor.loggingIn()
    
    
Template.nav.events
    # 'mouseenter .item': (e,t)->
    #     $(e.currentTarget).closest('.item').transition('pulse')
    # 'click .menu_dropdown': ->
        # $('.menu_dropdown').dropdown(
            # on:'hover'
        # )

    'click .logout': ->
        Session.set 'logging_out', true
        Meteor.logout ->
            Session.set 'logging_out', false
            # Router.go '/'

Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    # @autorun -> Meteor.subscribe 'users'
    # @autorun -> Meteor.subscribe 'users_by_role','staff'
    # @autorun -> Meteor.subscribe 'unread_messages'


Router.route '/', (->
    @render 'home'
    ), name:'home'
Router.route '/requests', (->
    @render 'requests'
    ), name:'requests'
Router.route '/transfers', (->
    @render 'transfers'
    ), name:'transfers'
Router.route '/group/:name', (->
    @render 'group'
    ), name:'group'

Template.items.onCreated ->
    @autorun -> Meteor.subscribe 'model_docs', 'item'
Template.transfers.onCreated ->
    @autorun -> Meteor.subscribe 'model_docs', 'request'
Template.requests.onCreated ->
    @autorun -> Meteor.subscribe 'model_docs', 'request'
Template.requests.onCreated ->
    @autorun -> Meteor.subscribe 'model_docs', 'item'
    # @autorun -> Meteor.subscribe 'model_docs', 'food'
    # @autorun -> Meteor.subscribe 'users'

# Template.delta.onRendered ->
#     Meteor.call 'log_view', @_id, ->

Template.request_item.events
    'click .cancel_request': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 1000)
        Meteor.setTimeout =>
            Docs.remove @_id
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@item_title} request canceled"
                # showProgress: 'bottom'
                class: 'error'
                # displayTime: 'auto',
                position: "bottom center"
            )
        , 1000
    
    'click .pick_up':(e,t)->
        $(e.currentTarget).closest('.grid').transition('fly left', 1000)
        Meteor.setTimeout =>
            Docs.update @_id, 
                $set:
                    status:'processing'
                    pick_up_timestamp:Date.now()
        , 500
        
        
    'click .mark_delivered': (e,t)->
        $(e.currentTarget).closest('.grid').transition('tada', 400)
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
        Meteor.setTimeout =>
            Docs.update @_id, 
                $set:
                    status:'delivered'
                    delivered_timestamp:Date.now()
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@item_title} marked delivered"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom center"
            )
        , 900
        
        
    'click .mark_complete': (e,t)->
        $(e.currentTarget).closest('.grid').transition('tada', 500)
        Meteor.setTimeout =>
            Docs.update @_id, 
                $set:
                    status:'complete'
                    complete_timestamp:Date.now()
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@item_title} completed"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom center"
            )
        , 500


Template.requests.helpers
    # roof_requests: ->
    #     Docs.find
    #         model:'request'
    #         _author_id: Meteor.userId()
    #         status: $ne:'delivered'
    unprocessed_requests: ->
        Docs.find
            model:'request'
            status: 'requested'
    processed_requests: ->
        Docs.find
            model:'request'
            status: 'processing'
            
            
Template.request_item.helpers
    delivery_time: ->
        moment_delivered = moment(@delivered_timestamp)
        moment_pickup = moment(@pick_up_timestamp)
        moment_delivered.diff(moment_pickup,'minutes');
    request_class: ->
        if @status is 'requested'
            'red'
        else if @status is 'processing'
            'yellow'
        else if @status is 'received'
            'green'
            
Template.items.helpers
    unarchived_items: ->
        Docs.find
            model:'item'
            archived:$ne:true
    archived_items: ->
        Docs.find
            model:'item'
            archived:true
            
Template.items.events
    'click .save_item': -> Session.set('editing_item', null)
    'click .edit_item': -> Session.set('editing_item',@_id) 
    'click .add_item': ->
        new_id = 
            Docs.insert 
                model:'item'
        Router.go "/item/#{new_id}/edit"
        # Session.set('editing_item', @_id)
            
            
Template.item_item.events
    'click .request_item': (e,t)->
        # if confirm 'request?'
        if Meteor.user()
            $(e.currentTarget).closest('.card').transition('bounce', 500)
            Docs.insert 
                model:'request'
                item_id:@_id
                item_title:@title
                item_image_id: @image_id
                status:'requested'
            $('body').toast(
                showIcon: 'bullhorn'
                message: "#{@title} requested"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom center"
            )
            
            
        
        
Template.role_picker.events
    'click .pick_user': ->
        # console.log @username
        # console.log @username
        Meteor.loginWithPassword(@name, @name, (e,r)=>
            if e
                if e.error is 403
                    Accounts.createUser({username:@name, password:@name}, (e,res)=>
                        console.log res
                        )
            else 
                console.log r
                $('body').toast(
                    showIcon: 'user'
                    message: "switched to #{@name}"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
                
        )        
                
                