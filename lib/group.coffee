if Meteor.isClient
    @picked_group_tags = new ReactiveArray []
    
    Router.route '/group/:doc_id', (->
        @layout 'group_layout'
        @render 'group_view'
        ), name:'group_view'
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    Router.route '/group/:doc_id/items', (->
        @layout 'group_layout'
        @render 'group_items'
        ), name:'group_items'
    Router.route '/group/:doc_id/members', (->
        @layout 'group_layout'
        @render 'group_members'
        ), name:'group_members'
    Router.route '/group/:doc_id/products', (->
        @layout 'group_layout'
        @render 'group_products'
        ), name:'group_products'
    Router.route '/group/:doc_id/work', (->
        @layout 'group_layout'
        @render 'group_work'
        ), name:'group_work'
    
            
    Template.groups.onCreated ->
        @autorun => @subscribe 'group_docs',
            picked_group_tags.array()
            Session.get('group_title_filter')
        @autorun => @subscribe 'group_facets',
            picked_group_tags.array()
            Session.get('group_title_filter')
    
    
    Template.group_products.onCreated ->
        @autorun => Meteor.subscribe 'group_model_docs', Router.current().params.doc_id, 'product',->
    Template.group_products.events
        'click .add_group_product': ->
            new_id = 
                Docs.insert
                    model:'product'
                    group_id:Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"
    
if Meteor.isServer
    Meteor.publish 'group_model_docs', (group_id,model)->
        Docs.find 
            model:model
            group_id:group_id
        
        
        
if Meteor.isClient
    Template.group_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'parent_group_from_child_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'child_groups_from_parent_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id, ->
    

    Template.group_view.helpers
        group_members: ->
            Meteor.users.find 
                membership_group_ids:$in:[Router.current().params.doc_id]
        
        is_member: ->
            Meteor.user().membership_group_ids and Router.current().params.doc_id in Meteor.user().membership_group_ids
        
        can_join: ->
            current_group = Docs.findOne Router.current().params.doc_id
            unless current_group.private
                unless Router.current().params.doc_id in Meteor.user().membership_group_ids
                    true
                else
                    false
            else
                true
        can_leave: ->
            current_group = Docs.findOne Router.current().params.doc_id
            unless current_group.private
                unless Router.current().params.doc_id in Meteor.user().membership_group_ids
                    true
                else
                    false
                # unless Meteor.userId() in current_group.member_ids
        
    Template.group_view.events
        'click .join': ->
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    membership_group_ids:Router.current().params.doc_id
        'click .leave': ->
            Meteor.users.update Meteor.userId(),
                $pull:
                    membership_group_ids:Router.current().params.doc_id
        
        'click .add_group_member': ->
            current_group_id = Router.current().params.doc_id
            new_username = prompt('new group member username')
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
                            membership_group_ids:current_group_id
                            # levels: 'customer'
                        # $set:
                        #     # first_name: Session.get('first_name')
                        #     # last_name: Session.get('last_name')
                        #     # app:'nf'
                        #     username:username
                    # Router.go "/user/#{username}"
            
            
            
    Template.groups.events
        'click .add_group': ->
            new_id = Docs.insert 
                model:'group'
            Router.go "/group/#{new_id}/edit"    
        'click .pick_group_tag': -> picked_group_tags.push @title
        'click .unpick_group_tag': -> picked_group_tags.remove @valueOf()

                
            
    Template.groups.helpers
        picked_group_tags: -> picked_group_tags.array()
        current_group_title_filter: ->
            Session.get('group_title_filter')
        group_docs: ->
            match = {model:'group'}
            if Session.get('group_title_filter')
                match.title = {$regex:Session.get('group_title_filter'), $options:'i'}
            Docs.find match
            
            
        group_tag_results: ->
            Results.find {
                model:'group_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'group_members', (group_id)->
        Meteor.users.find   
            membership_group_ids:$in:[group_id]
            


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
        @autorun => Meteor.subscribe 'parent_group_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'group'


    Template.group_edit.helpers
        nonparent_groups: ->
            current_group = 
                Docs.findOne Router.current().params.doc_id
            if current_group and current_group.parent_group_id
                Docs.find
                    model:'group'
                    # _author_id:Meteor.userId()
                    _id:$nin:[current_group.parent_group_id]
            else 
                Docs.find
                    model:'group'
                    _id:$ne:current_group._id
  
  
    Template.group_edit.events
        'click .delete_group':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/groups"
            
        'click .set_parent': ->
            Docs.update Router.current().params.doc_id, 
                $set: 
                    parent_group_id:@_id
                    
        'click .clear_parent_group': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $unset: 
                        parent_group_id:1
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
    Meteor.publish 'parent_group_from_child_id', (child_id)->
        group = Docs.findOne child_id
        Docs.find 
            model:'group'
            _id:group.parent_group_id
            
    Meteor.publish 'child_groups_from_parent_id', (parent_id)->
        group = Docs.findOne parent_id
        Docs.find 
            model:'group'
            parent_group_id:parent_id
            
            