if Meteor.isClient
    Router.route '/group/:doc_id', (->
        @layout 'layout'
        @render 'group_view'
        ), name:'group_view'
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    
            
    Template.groups.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group', ->
    
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_work', Router.current().params.doc_id, ->
    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_work', Router.current().params.doc_id, ->
    


    Template.groups.events
        'click .add_group': ->
            new_id = Docs.insert 
                model:'group'
            Router.go "/group/#{new_id}/edit"    
    
                
            
    Template.groups.helpers
        group_docs: ->
            Docs.find 
                model:'group'
                
                
        
if Meteor.isServer
    Meteor.publish 'user_sent_group', (username)->
        Docs.find   
            model:'group'
            _author_username:username
    Meteor.publish 'product_group', (product_id)->
        Docs.find   
            model:'group'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/group/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_edit'
        ), name:'group_edit'



    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.group_edit.events
        'click .send_group': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    group = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update group._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'group sent',
                        ''
                        'success'
                    Router.go "/group/#{@_id}/"
                    )
            )

        'click .delete_group':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/group"
            