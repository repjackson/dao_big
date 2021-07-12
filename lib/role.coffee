if Meteor.isClient
    Router.route '/role/:doc_id', (->
        @layout 'layout'
        @render 'role_view'
        ), name:'role_view'
    Router.route '/roles', (->
        @layout 'layout'
        @render 'roles'
        ), name:'roles'
    
            
    Template.roles.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'role', ->
    
    Template.role_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'role_work', Router.current().params.doc_id, ->
    Template.role_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'role_work', Router.current().params.doc_id, ->
    


    Template.roles.events
        'click .add_role': ->
            new_id = Docs.insert 
                model:'role'
            Router.go "/role/#{new_id}/edit"    
    
    Template.role_view.events
        'click .add_role_task': ->
            new_id = Docs.insert 
                model:'task'
                role_id:Router.current().params.doc_id
            Router.go "/task/#{new_id}/edit"    
    
                
            
    Template.roles.helpers
        role_docs: ->
            Docs.find 
                model:'role'
                
                
        
if Meteor.isServer
    Meteor.publish 'product_role', (product_id)->
        Docs.find   
            model:'role'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/role/:doc_id/edit', (->
        @layout 'layout'
        @render 'role_edit'
        ), name:'role_edit'



    Template.role_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.role_edit.events
        'click .send_role': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    role = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update role._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'role sent',
                        ''
                        'success'
                    Router.go "/role/#{@_id}/"
                    )
            )

        'click .delete_role':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/role"
            