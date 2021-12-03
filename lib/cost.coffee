if Meteor.isClient
    @picked_cost_tags = new ReactiveArray []
    
    Router.route '/cost/:doc_id', (->
        @layout 'layout'
        @render 'cost_view'
        ), name:'cost_view'
    Router.route '/costs', (->
        @layout 'layout'
        @render 'costs'
        ), name:'costs'
    
            
    Template.costs.onCreated ->
        @autorun => @subscribe 'cost_docs',
            picked_cost_tags.array()
            Session.get('cost_title_filter')
        @autorun => @subscribe 'cost_facets',
            picked_cost_tags.array()
            Session.get('cost_title_filter')
    
    
if Meteor.isServer
    Meteor.publish 'cost_model_docs', (cost_id,model)->
        Docs.find 
            model:model
            cost_id:cost_id
        
    
    Meteor.publish 'cost_docs', (cost_id,model)->
        Docs.find 
            model:'cost'
        
if Meteor.isClient
    Template.cost_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'cost_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'parent_cost_from_child_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'child_costs_from_parent_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'cost_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'cost_products', Router.current().params.doc_id, ->
    

    Template.cost_view.helpers
        cost_members: ->
            Meteor.users.find 
                membership_cost_ids:$in:[Router.current().params.doc_id]
        
        cost_products: ->
            Docs.find 
                model:'product'
                cost_id:Router.current().params.doc_id
        
        is_member: ->
            Meteor.user().membership_cost_ids and Router.current().params.doc_id in Meteor.user().membership_cost_ids
        
        can_join: ->
            current_cost = Docs.findOne Router.current().params.doc_id
            unless current_cost.private
                unless Router.current().params.doc_id in Meteor.user().membership_cost_ids
                    true
                else
                    false
            else
                true
        can_leave: ->
            current_cost = Docs.findOne Router.current().params.doc_id
            unless current_cost.private
                unless Router.current().params.doc_id in Meteor.user().membership_cost_ids
                    true
                else
                    false
                # unless Meteor.userId() in current_cost.member_ids
        
    Template.cost_view.events
        'click .join': ->
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    membership_cost_ids:Router.current().params.doc_id
        'click .leave': ->
            Meteor.users.update Meteor.userId(),
                $pull:
                    membership_cost_ids:Router.current().params.doc_id
        
        'click .add_cost_member': ->
            current_cost_id = Router.current().params.doc_id
            new_username = prompt('new cost member username')
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
                            membership_cost_ids:current_cost_id
                            # levels: 'customer'
                        # $set:
                        #     # first_name: Session.get('first_name')
                        #     # last_name: Session.get('last_name')
                        #     # app:'nf'
                        #     username:username
                    # Router.go "/user/#{username}"
            
            
            
    Template.costs.events
        'click .add_cost': ->
            new_id = Docs.insert 
                model:'cost'
            Router.go "/cost/#{new_id}/edit"    
        'click .pick_cost_tag': -> picked_cost_tags.push @title
        'click .unpick_cost_tag': -> picked_cost_tags.remove @valueOf()

                
            
    Template.costs.helpers
        picked_cost_tags: -> picked_cost_tags.array()
        current_cost_title_filter: ->
            Session.get('cost_title_filter')
        cost_docs: ->
            match = {model:'cost'}
            if Session.get('cost_title_filter')
                match.title = {$regex:Session.get('cost_title_filter'), $options:'i'}
            Docs.find match
            
            
        cost_tag_results: ->
            Results.find {
                model:'cost_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'cost_members', (cost_id)->
        Meteor.users.find   
            membership_cost_ids:$in:[cost_id]
            


if Meteor.isClient
    Router.route '/cost/:doc_id/edit', (->
        @layout 'layout'
        @render 'cost_edit'
        ), name:'cost_edit'



    Template.cost_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_cost_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'cost'


    Template.cost_edit.helpers
        nonparent_costs: ->
            current_cost = 
                Docs.findOne Router.current().params.doc_id
            if current_cost and current_cost.parent_cost_id
                Docs.find
                    model:'cost'
                    # _author_id:Meteor.userId()
                    # _id:$nin:[current_cost.parent_cost_id]
            else 
                Docs.find
                    model:'cost'
                    # _id:$ne:current_cost._id
  
  
    Template.cost_edit.events
        'click .delete_cost':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/costs"
            
        'click .set_parent': ->
            Docs.update Router.current().params.doc_id, 
                $set: 
                    parent_cost_id:@_id
                    
        'click .clear_parent_cost': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $unset: 
                        parent_cost_id:1
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
    Meteor.publish 'parent_cost_from_child_id', (child_id)->
        cost = Docs.findOne child_id
        if cost.parent_cost_id
            Docs.find 
                model:'cost'
                _id:cost.parent_cost_id
                
    Meteor.publish 'cost_products', (cost_id)->
        # cost = Docs.findOne child_id
        Docs.find
            model:'product'
            cost_id:cost_id
            
            
    Meteor.publish 'child_costs_from_parent_id', (parent_id)->
        cost = Docs.findOne parent_id
        Docs.find 
            model:'cost'
            parent_cost_id:parent_id
            
            