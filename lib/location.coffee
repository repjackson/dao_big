if Meteor.isClient
    Router.route '/location/:doc_id', (->
        @layout 'layout'
        @render 'location_view'
        ), name:'location_view'
    Router.route '/locations', (->
        @layout 'layout'
        @render 'locations'
        ), name:'locations'
    
            
    Template.locations.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    
    Template.location_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'location_work', Router.current().params.doc_id, ->
    Template.location_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'location_work', Router.current().params.doc_id, ->
    


    Template.locations.events
        'click .add_location': ->
            new_id = Docs.insert 
                model:'location'
            Router.go "/location/#{new_id}/edit"    
    
                
            
    Template.locations.helpers
        location_docs: ->
            Docs.find 
                model:'location'
                
                
        
if Meteor.isServer
    Meteor.publish 'user_sent_location', (username)->
        Docs.find   
            model:'location'
            _author_username:username
    Meteor.publish 'product_location', (product_id)->
        Docs.find   
            model:'location'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/location/:doc_id/edit', (->
        @layout 'layout'
        @render 'location_edit'
        ), name:'location_edit'



    Template.location_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.location_edit.events
        'click .send_location': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    location = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update location._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'location sent',
                        ''
                        'success'
                    Router.go "/location/#{@_id}/"
                    )
            )

        'click .delete_location':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/location"
            