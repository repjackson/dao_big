if Meteor.isClient
    Router.route '/', (->
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'service'
        # @autorun -> Meteor.subscribe 'model_docs', 'rental'
        @autorun -> Meteor.subscribe 'model_docs', 'item'
        @autorun -> Meteor.subscribe 'model_docs', 'item_request'
        # @autorun -> Meteor.subscribe 'model_docs', 'food'
        # @autorun -> Meteor.subscribe 'users'

    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.item_card.events
        'click .request_item': ->
            Docs.insert 
                model:'item_request'
                item_id:@_id
                item_title:@title
    Template.home.helpers
        items: ->
            Docs.find
                model:'item'
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
            console.log @username
            console.log @username
            Meteor.loginWithPassword(@name, @name, (e,r)=>
                if e
                    if e.error is 403
                        Accounts.createUser({username:@name, password:@name}, (e,res)=>
                            console.log res
                            )
                else 
                    console.log r
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