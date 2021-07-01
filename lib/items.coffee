if Meteor.isClient
    Router.route '/item/:doc_id', (->
        @layout 'layout'
        @render 'item_view'
        ), name:'item_view'
    Router.route '/items', (->
        @layout 'layout'
        @render 'items'
        ), name:'items'
    
    Template.items.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'item', ->
            
            
    Template.item_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.item_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    
    Template.item_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'item_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    Template.item_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'item_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


    Template.item_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                item_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.item_view.helpers
        item_work: ->
            Docs.find   
                model:'work'
                item_id:Router.current().params.doc_id

        possible_locations: ->
            item = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:item.location_ids
    Template.item_edit.helpers
        item_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            item = Docs.findOne Router.current().params.doc_id
            if item.location_ids and @_id in item.location_ids then 'blue' else 'basic'
            
                
    Template.item_edit.events
        'click .select_location': ->
            item = Docs.findOne Router.current().params.doc_id
            if item.location_ids and @_id in item.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id
            
if Meteor.isServer
    Meteor.publish 'item_work', (item_id)->
        Docs.find   
            model:'work'
            item_id:item_id
            
    # Meteor.publish 'work_item', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'item'
    #         _id: work.item_id
            
            
    Meteor.publish 'user_sent_item', (username)->
        Docs.find   
            model:'item'
            _author_username:username
    Meteor.publish 'product_item', (product_id)->
        Docs.find   
            model:'item'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/item/:doc_id/edit', (->
        @layout 'layout'
        @render 'item_edit'
        ), name:'item_edit'



    Template.item_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.item_edit.events
        'click .send_item': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    item = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update item._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'item sent',
                        ''
                        'success'
                    Router.go "/item/#{@_id}/"
                    )
            )

        'click .delete_item':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/items"
            
    Template.item_edit.helpers
        all_shop: ->
            Docs.find
                model:'item'
