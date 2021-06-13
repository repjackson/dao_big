if Meteor.isClient
    Router.route '/', (->
        @render 'home'
        ), name:'home'
    Router.route '/requests', (->
        @render 'requests'
        ), name:'requests'
    Router.route '/transfers', (->
        @render 'transfers'
        ), name:'transfers'

    Template.items.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'service'
        # @autorun -> Meteor.subscribe 'model_docs', 'rental'
        @autorun -> Meteor.subscribe 'model_docs', 'item'
    Template.transfers.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'request'
    Template.requests.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'request'
        # @autorun -> Meteor.subscribe 'model_docs', 'food'
        # @autorun -> Meteor.subscribe 'users'

    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.request_item.events
        'click .pick_up': ->
            if confirm 'pick up?'
                Docs.update @_id, 
                    $set:
                        status:'processing'
                        pick_up_timestamp:Date.now()
        'click .mark_delivered': ->
            if confirm 'mark delivered?'
                Docs.update @_id, 
                    $set:
                        status:'delivered'
                        delivered_timestamp:Date.now()
    Template.item_card.events
        'click .request_item': ->
            if confirm 'request?'
                Docs.insert 
                    model:'request'
                    item_id:@_id
                    item_title:@title
                    item_image_id: @image_id
                    status:'requested'
    Template.items.helpers
        item_docs: ->
            Docs.find
                model:'item'
    Template.requests.helpers
        your_request_docs: ->
            Docs.find
                model:'request'
                _author_id: Meteor.userId()
        request_docs: ->
            Docs.find
                model:'request'
    Template.transfers.helpers
        request_docs: ->
            Docs.find
                model:'request'
    Template.request_item.helpers
        is_porters: ->
            console.log Meteor.user().username
            Meteor.user().username is 'porters'
        is_requester: ->
            @_author_username is Meteor.user().username
        is_requested: -> @status is 'requested'
        is_processing: -> @status is 'processing'
        is_delivered: -> @status is 'delivered'
        
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
                        position: "top right"
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