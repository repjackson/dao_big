if Meteor.isClient
    @picked_event_tags = new ReactiveArray []
    
    Router.route '/event/:doc_id', (->
        @layout 'layout'
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

    Template.events.events
        'click .add_event': ->
            new_id = Docs.insert 
                model:'event'
            Router.go "/event/#{new_id}/edit"    
        'click .pick_event_tag': -> picked_event_tags.push @title
        'click .unpick_event_tag': -> picked_event_tags.remove @valueOf()

                
            
    Template.events.helpers
        picked_event_tags: -> picked_event_tags.array()
    
        event_docs: ->
            Docs.find 
                model:'event'
        event_tag_results: ->
            Results.find {
                model:'event_tag'
            }, sort:_timestamp:-1
  
                

            
    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    
    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'event_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'event_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


    Template.event_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                event_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.event_view.helpers
        possible_locations: ->
            event = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:event.location_ids
    Template.event_edit.helpers
        event_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            event = Docs.findOne Router.current().params.doc_id
            if event.location_ids and @_id in event.location_ids then 'blue' else 'basic'
            
                
    Template.event_edit.events
        'click .select_location': ->
            event = Docs.findOne Router.current().params.doc_id
            if event.location_ids and @_id in event.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id
            
if Meteor.isServer
    Meteor.publish 'event_work', (event_id)->
        Docs.find   
            model:'work'
            event_id:event_id
            
    # Meteor.publish 'work_event', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'event'
    #         _id: work.event_id
            
            
    Meteor.publish 'user_sent_event', (username)->
        Docs.find   
            model:'event'
            _author_username:username
    Meteor.publish 'product_event', (product_id)->
        Docs.find   
            model:'event'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/event/:doc_id/edit', (->
        @layout 'layout'
        @render 'event_edit'
        ), name:'event_edit'



    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.event_edit.events
        'click .send_event': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    event = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update event._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'event sent',
                        ''
                        'success'
                    Router.go "/event/#{@_id}/"
                    )
            )

        'click .delete_event':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/events"
            
    Template.event_edit.helpers
        all_shop: ->
            Docs.find
                model:'event'
