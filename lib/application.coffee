if Meteor.isClient
    @picked_application_tags = new ReactiveArray []
    
    Router.route '/application/:doc_id', (->
        @layout 'layout'
        @render 'application_view'
        ), name:'application_view'
    Router.route '/applications', (->
        @layout 'layout'
        @render 'applications'
        ), name:'applications'
    
            
    Template.applications.onCreated ->
        @autorun => @subscribe 'application_docs',
            picked_application_tags.array()
            Session.get('application_title_filter')
        @autorun => @subscribe 'application_facets',
            picked_application_tags.array()
            Session.get('application_title_filter')
    
    
if Meteor.isServer
    Meteor.publish 'application_model_docs', (application_id,model)->
        Docs.find 
            model:model
            application_id:application_id
        
    
    Meteor.publish 'application_docs', (application_id,model)->
        Docs.find 
            model:'application'
        
if Meteor.isClient
    Template.application_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'application_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'parent_application_from_child_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'child_applications_from_parent_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'application_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'application_products', Router.current().params.doc_id, ->
    

    Template.application_view.helpers
        application_members: ->
            Meteor.users.find 
                membership_application_ids:$in:[Router.current().params.doc_id]
        
        application_products: ->
            Docs.find 
                model:'product'
                application_id:Router.current().params.doc_id
        
        is_member: ->
            Meteor.user().membership_application_ids and Router.current().params.doc_id in Meteor.user().membership_application_ids
        
        can_join: ->
            current_application = Docs.findOne Router.current().params.doc_id
            unless current_application.private
                unless Router.current().params.doc_id in Meteor.user().membership_application_ids
                    true
                else
                    false
            else
                true
        can_leave: ->
            current_application = Docs.findOne Router.current().params.doc_id
            unless current_application.private
                unless Router.current().params.doc_id in Meteor.user().membership_application_ids
                    true
                else
                    false
                # unless Meteor.userId() in current_application.member_ids
        
    Template.application_view.events
        'click .join': ->
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    membership_application_ids:Router.current().params.doc_id
        'click .leave': ->
            Meteor.users.update Meteor.userId(),
                $pull:
                    membership_application_ids:Router.current().params.doc_id
        
        'click .add_application_member': ->
            current_application_id = Router.current().params.doc_id
            new_username = prompt('new application member username')
            console.log new_username
            
            options = {
                username:new_username
                password:new_username
                }
            console.log new_username
            Meteor.call 'create_user', options, (err,res)=>
                if err
                    alert err
                else
                    console.log res
                    # unless username
                    #     username = "#{Session.get('first_name').toLowerCase()}_#{Session.get('last_name').toLowerCase()}"
                    # console.log username
                    Meteor.users.update res,
                        $addToSet: 
                            roles: 'employee'
                            membership_application_ids:current_application_id
                            # levels: 'customer'
                        # $set:
                        #     # first_name: Session.get('first_name')
                        #     # last_name: Session.get('last_name')
                        #     # application:'nf'
                        #     username:username
                    # Router.go "/user/#{username}"
            
            
            
    Template.applications.events
        'click .add_application': ->
            new_id = Docs.insert 
                model:'application'
            Router.go "/application/#{new_id}/edit"    
        'click .pick_application_tag': -> picked_application_tags.push @title
        'click .unpick_application_tag': -> picked_application_tags.remove @valueOf()

                
            
    Template.applications.helpers
        picked_application_tags: -> picked_application_tags.array()
        current_application_title_filter: ->
            Session.get('application_title_filter')
        application_docs: ->
            match = {model:'application'}
            if Session.get('application_title_filter')
                match.title = {$regex:Session.get('application_title_filter'), $options:'i'}
            Docs.find match
            
            
        application_tag_results: ->
            Results.find {
                model:'application_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'application_members', (application_id)->
        Meteor.users.find   
            membership_application_ids:$in:[application_id]
            


if Meteor.isClient
    Router.route '/application/:doc_id/edit', (->
        @layout 'layout'
        @render 'application_edit'
        ), name:'application_edit'



    Template.application_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_application_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'application'


    Template.application_edit.helpers
        nonparent_applications: ->
            current_application = 
                Docs.findOne Router.current().params.doc_id
            if current_application and current_application.parent_application_id
                Docs.find
                    model:'application'
                    # _author_id:Meteor.userId()
                    # _id:$nin:[current_application.parent_application_id]
            else 
                Docs.find
                    model:'application'
                    # _id:$ne:current_application._id
  
  
    Template.application_edit.events
        'click .delete_application':->
            # if confirm 'delete?'
            Swal.fire({
                title: 'confirm delete application'
                # text: "#{@amount} credits"
                icon: 'alert'
                showCancelButton: true,
                confirmButtonText: 'delete app'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    # payment = Docs.findOne Router.current().params.doc_id
                    # Meteor.users.update Meteor.userId(),
                    #     $inc:credit:-@amount
                    # Docs.update payment._id,
                    #     $set:
                    #         sent:true
                    Docs.remove @_id
                    #         sent_timestamp:Date.now()
                    Swal.fire(
                        'application deleted',
                        ''
                        'success'
                    Router.go "/unit/#{@unit_id}"
                    )
            )
                
            
        'click .set_parent': ->
            Docs.update Router.current().params.doc_id, 
                $set: 
                    parent_application_id:@_id
                    
        'click .clear_parent_application': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $unset: 
                        parent_application_id:1
                $('body').toast(
                    showIcon: 'remove'
                    message: "#{@title} removed as parent"
                    # showProgress: 'bottom'
                    class: 'error'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
            , 600
            
                    
            
            
if Meteor.isServer
    Meteor.publish 'parent_application_from_child_id', (child_id)->
        application = Docs.findOne child_id
        if application.parent_application_id
            Docs.find 
                model:'application'
                _id:application.parent_application_id
                
    Meteor.publish 'application_products', (application_id)->
        # application = Docs.findOne child_id
        Docs.find
            model:'product'
            application_id:application_id
            
            
    Meteor.publish 'child_applications_from_parent_id', (parent_id)->
        application = Docs.findOne parent_id
        Docs.find 
            model:'application'
            parent_application_id:parent_id
            
            