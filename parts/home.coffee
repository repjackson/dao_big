if Meteor.isClient
    Router.route '/', (->
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'service'
        # @autorun -> Meteor.subscribe 'model_docs', 'rental'
        # @autorun -> Meteor.subscribe 'model_docs', 'role'
        # @autorun -> Meteor.subscribe 'model_docs', 'food'
        # @autorun -> Meteor.subscribe 'users'

    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

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