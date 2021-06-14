@picked_tags = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0



$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.body.events
    'click a': ->
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
            Router.go '/'

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
Router.route '/items', (->
    @render 'items'
    ), name:'items'
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
        $(e.currentTarget).closest('.grid').transition('slide right', 500)
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
        , 250
    
    'click .pick_up': ->
        # if confirm 'pick up?'
        Docs.update @_id, 
            $set:
                status:'processing'
                pick_up_timestamp:Date.now()
    'click .mark_delivered': ->
        # if confirm 'mark delivered?'
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
Template.item_item.events
    'click .request_item': (e,t)->
        # if confirm 'request?'
        $(e.currentTarget).closest('.card').transition('pulse', 200)
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
            
            
Template.items.helpers
    item_docs: ->
        Docs.find
            model:'item'
Template.requests.helpers
    your_request_docs: ->
        Docs.find
            model:'request'
            _author_id: Meteor.userId()
            status: $ne:'delivered'
    request_docs: ->
        Docs.find
            model:'request'
            status: $ne:'delivered'
Template.transfers.helpers
    request_docs: ->
        Docs.find
            model:'request'
Template.request_item.helpers
    # is_porters: ->
    #     console.log Meteor.user().username
    #     Meteor.user().username is 'porters'
    # is_requester: ->
    #     @_author_username is Meteor.user().username
    # is_requested: -> @status is 'requested'
    # is_processing: -> @status is 'processing'
    # is_delivered: -> @status is 'delivered'
    
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
Template.home.events
    'click .save_item': ->
        Session.set('editing_item', null)
    'click .edit_item': ->
        Session.set('editing_item',@_id) 
    'click .add_item': ->
        new_id = 
            Docs.insert 
                model:'item'
        Session.set('editing_item', @_id)
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
                    message: @name
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
                
        )        
                
                
Template.home.events
    'click .add_role': ->
        new_id = 
            Docs.insert 
                model:'role'
        
Template.home.helpers
    role_docs: ->
        Docs.find
            model:'role'
