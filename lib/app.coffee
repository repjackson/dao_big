if Meteor.isClient
    @picked_app_tags = new ReactiveArray []
    
    Router.route '/app/:doc_id', (->
        @layout 'layout'
        @render 'app_view'
        ), name:'app_view'
    Router.route '/apps', (->
        @layout 'layout'
        @render 'apps'
        ), name:'apps'
    
            
    Template.apps.onCreated ->
        @autorun => @subscribe 'app_docs',
            picked_app_tags.array()
            Session.get('app_title_filter')
        @autorun => @subscribe 'app_facets',
            picked_app_tags.array()
            Session.get('app_title_filter')
    
    
if Meteor.isServer
    Meteor.publish 'app_model_docs', (app_id,model)->
        Docs.find 
            model:model
            app_id:app_id
        
    
    Meteor.publish 'app_docs', (app_id,model)->
        Docs.find 
            model:'app'
        
if Meteor.isClient
    Template.app_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'app_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'parent_app_from_child_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'child_apps_from_parent_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'app_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'app_products', Router.current().params.doc_id, ->
    

    Template.app_view.helpers
        app_members: ->
            Meteor.users.find 
                membership_app_ids:$in:[Router.current().params.doc_id]
        
        app_products: ->
            Docs.find 
                model:'product'
                app_id:Router.current().params.doc_id
        
        is_member: ->
            Meteor.user().membership_app_ids and Router.current().params.doc_id in Meteor.user().membership_app_ids
        
        can_join: ->
            current_app = Docs.findOne Router.current().params.doc_id
            unless current_app.private
                unless Router.current().params.doc_id in Meteor.user().membership_app_ids
                    true
                else
                    false
            else
                true
        can_leave: ->
            current_app = Docs.findOne Router.current().params.doc_id
            unless current_app.private
                unless Router.current().params.doc_id in Meteor.user().membership_app_ids
                    true
                else
                    false
                # unless Meteor.userId() in current_app.member_ids
        
    Template.app_view.events
        'click .join': ->
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    membership_app_ids:Router.current().params.doc_id
        'click .leave': ->
            Meteor.users.update Meteor.userId(),
                $pull:
                    membership_app_ids:Router.current().params.doc_id
        
        'click .add_app_member': ->
            current_app_id = Router.current().params.doc_id
            new_username = prompt('new app member username')
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
                            membership_app_ids:current_app_id
                            # levels: 'customer'
                        # $set:
                        #     # first_name: Session.get('first_name')
                        #     # last_name: Session.get('last_name')
                        #     # app:'nf'
                        #     username:username
                    # Router.go "/user/#{username}"
            
            
            
    Template.apps.events
        'click .add_app': ->
            new_id = Docs.insert 
                model:'app'
            Router.go "/app/#{new_id}/edit"    
        'click .pick_app_tag': -> picked_app_tags.push @title
        'click .unpick_app_tag': -> picked_app_tags.remove @valueOf()

                
            
    Template.apps.helpers
        picked_app_tags: -> picked_app_tags.array()
        current_app_title_filter: ->
            Session.get('app_title_filter')
        app_docs: ->
            match = {model:'app'}
            if Session.get('app_title_filter')
                match.title = {$regex:Session.get('app_title_filter'), $options:'i'}
            Docs.find match
            
            
        app_tag_results: ->
            Results.find {
                model:'app_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'app_members', (app_id)->
        Meteor.users.find   
            membership_app_ids:$in:[app_id]
            


if Meteor.isClient
    Router.route '/app/:doc_id/edit', (->
        @layout 'layout'
        @render 'app_edit'
        ), name:'app_edit'



    Template.app_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_app_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'app'


    Template.app_edit.helpers
        nonparent_apps: ->
            current_app = 
                Docs.findOne Router.current().params.doc_id
            if current_app and current_app.parent_app_id
                Docs.find
                    model:'app'
                    # _author_id:Meteor.userId()
                    # _id:$nin:[current_app.parent_app_id]
            else 
                Docs.find
                    model:'app'
                    # _id:$ne:current_app._id
  
  
    Template.app_edit.events
        'click .delete_app':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/apps"
            
        'click .set_parent': ->
            Docs.update Router.current().params.doc_id, 
                $set: 
                    parent_app_id:@_id
                    
        'click .clear_parent_app': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $unset: 
                        parent_app_id:1
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
    Meteor.publish 'parent_app_from_child_id', (child_id)->
        app = Docs.findOne child_id
        if app.parent_app_id
            Docs.find 
                model:'app'
                _id:app.parent_app_id
                
    Meteor.publish 'app_products', (app_id)->
        # app = Docs.findOne child_id
        Docs.find
            model:'product'
            app_id:app_id
            
            
    Meteor.publish 'child_apps_from_parent_id', (parent_id)->
        app = Docs.findOne parent_id
        Docs.find 
            model:'app'
            parent_app_id:parent_id
            
            