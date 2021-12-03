if Meteor.isClient
    @picked_event_tags = new ReactiveArray []
    
    Router.route '/event/:doc_id', (->
        @layout 'event_layout'
        @render 'event_view'
        ), name:'event_view'
    Router.route '/events', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'
    
            
    Template.events.onCreated ->
        @autorun => @subscribe 'event_docs',
            picked_event_tags.array()
            Session.get('event_title_filter')
        @autorun => @subscribe 'event_facets',
            picked_event_tags.array()
            Session.get('event_title_filter')
    
    
if Meteor.isServer
    Meteor.publish 'event_model_docs', (event_id,model)->
        Docs.find 
            model:model
            event_id:event_id
        
    
    Meteor.publish 'event_docs', (event_id,model)->
        Docs.find 
            model:'event'
        
if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'event_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'parent_event_from_child_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'child_events_from_parent_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'event_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'event_products', Router.current().params.doc_id, ->
    

    Template.event_view.helpers
        event_members: ->
            Meteor.users.find 
                membership_event_ids:$in:[Router.current().params.doc_id]
        
        event_products: ->
            Docs.find 
                model:'product'
                event_id:Router.current().params.doc_id
        
        is_member: ->
            Meteor.user().membership_event_ids and Router.current().params.doc_id in Meteor.user().membership_event_ids
        
        can_join: ->
            current_event = Docs.findOne Router.current().params.doc_id
            unless current_event.private
                unless Router.current().params.doc_id in Meteor.user().membership_event_ids
                    true
                else
                    false
            else
                true
        can_leave: ->
            current_event = Docs.findOne Router.current().params.doc_id
            unless current_event.private
                unless Router.current().params.doc_id in Meteor.user().membership_event_ids
                    true
                else
                    false
                # unless Meteor.userId() in current_event.member_ids
        
    Template.event_view.events
        'click .join': ->
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    membership_event_ids:Router.current().params.doc_id
        'click .leave': ->
            Meteor.users.update Meteor.userId(),
                $pull:
                    membership_event_ids:Router.current().params.doc_id
        
        'click .add_event_member': ->
            current_event_id = Router.current().params.doc_id
            new_username = prompt('new event member username')
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
                            membership_event_ids:current_event_id
                            # levels: 'customer'
                        # $set:
                        #     # first_name: Session.get('first_name')
                        #     # last_name: Session.get('last_name')
                        #     # app:'nf'
                        #     username:username
                    # Router.go "/user/#{username}"
            
            
            
    Template.events.events
        'click .add_event': ->
            new_id = Docs.insert 
                model:'event'
            Router.go "/event/#{new_id}/edit"    
        'click .pick_event_tag': -> picked_event_tags.push @title
        'click .unpick_event_tag': -> picked_event_tags.remove @valueOf()

                
            
    Template.events.helpers
        picked_event_tags: -> picked_event_tags.array()
        current_event_title_filter: ->
            Session.get('event_title_filter')
        event_docs: ->
            match = {model:'event'}
            if Session.get('event_title_filter')
                match.title = {$regex:Session.get('event_title_filter'), $options:'i'}
            Docs.find match
            
            
        event_tag_results: ->
            Results.find {
                model:'event_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'event_members', (event_id)->
        Meteor.users.find   
            membership_event_ids:$in:[event_id]
            


if Meteor.isClient
    Router.route '/event/:doc_id/edit', (->
        @layout 'layout'
        @render 'event_edit'
        ), name:'event_edit'



    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_event_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'event'


    Template.event_edit.helpers
        nonparent_events: ->
            current_event = 
                Docs.findOne Router.current().params.doc_id
            if current_event and current_event.parent_event_id
                Docs.find
                    model:'event'
                    # _author_id:Meteor.userId()
                    # _id:$nin:[current_event.parent_event_id]
            else 
                Docs.find
                    model:'event'
                    # _id:$ne:current_event._id
  
  
    Template.event_edit.events
        'click .delete_event':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/events"
            
        'click .set_parent': ->
            Docs.update Router.current().params.doc_id, 
                $set: 
                    parent_event_id:@_id
                    
        'click .clear_parent_event': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $unset: 
                        parent_event_id:1
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
    Meteor.publish 'parent_event_from_child_id', (child_id)->
        event = Docs.findOne child_id
        if event.parent_event_id
            Docs.find 
                model:'event'
                _id:event.parent_event_id
                
    Meteor.publish 'event_products', (event_id)->
        # event = Docs.findOne child_id
        Docs.find
            model:'product'
            event_id:event_id
            
            
    Meteor.publish 'child_events_from_parent_id', (parent_id)->
        event = Docs.findOne parent_id
        Docs.find 
            model:'event'
            parent_event_id:parent_id
            
            