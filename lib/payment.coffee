if Meteor.isClient
    @picked_payment_tags = new ReactiveArray []
    
    Router.route '/payment/:doc_id', (->
        @layout 'layout'
        @render 'payment_view'
        ), name:'payment_view'
    Router.route '/payments', (->
        @layout 'layout'
        @render 'payments'
        ), name:'payments'
    
    Template.payments.onCreated ->
        @autorun => @subscribe 'payment_docs',
            picked_payment_tags.array()
            Session.get('payment_title_filter')

        @autorun => @subscribe 'payment_facets',
            picked_payment_tags.array()
            Session.get('payment_title_filter')

    Template.payments.events
        'click .add_payment': ->
            new_id = Docs.insert 
                model:'payment'
            Router.go "/payment/#{new_id}/edit"    
        'click .pick_payment_tag': -> picked_payment_tags.push @title
        'click .unpick_payment_tag': -> picked_payment_tags.remove @valueOf()

                
            
    Template.payments.helpers
        picked_payment_tags: -> picked_payment_tags.array()
    
        payment_docs: ->
            Docs.find 
                model:'payment'
                # group_id: Meteor.user().current_group_id
                
        payment_tag_results: ->
            Results.find {
                model:'payment_tag'
            }, sort:_timestamp:-1
  
                

            
    Template.payment_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'payment_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'child_groups_from_parent_id', Router.current().params.doc_id,->
 
    Template.payment_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'payment_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


    Template.payment_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                payment_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.payment_view.helpers
        possible_locations: ->
            payment = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:payment.location_ids
                
        payment_work: ->
            Docs.find 
                model:'work'
                payment_id:Router.current().params.doc_id
                
    Template.payment_edit.helpers
        payment_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            payment = Docs.findOne Router.current().params.doc_id
            if payment.location_ids and @_id in payment.location_ids then 'blue' else 'basic'
            
                
    Template.payment_edit.events
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    complete:true
                    complete_timestamp: Date.now()
                    
        'click .select_location': ->
            payment = Docs.findOne Router.current().params.doc_id
            if payment.location_ids and @_id in payment.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id
            
if Meteor.isServer
    Meteor.publish 'payment_work', (payment_id)->
        Docs.find   
            model:'work'
            payment_id:payment_id
    # Meteor.publish 'work_payment', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'payment'
    #         _id: work.payment_id
            
            
    Meteor.publish 'user_sent_payment', (username)->
        Docs.find   
            model:'payment'
            _author_username:username
    Meteor.publish 'product_payment', (product_id)->
        Docs.find   
            model:'payment'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/payment/:doc_id/edit', (->
        @layout 'layout'
        @render 'payment_edit'
        ), name:'payment_edit'



    Template.payment_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.payment_edit.events
        'click .send_payment': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    payment = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update payment._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'payment sent',
                        ''
                        'success'
                    Router.go "/payment/#{@_id}/"
                    )
            )

        'click .delete_payment':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/payments"
            
    Template.payment_edit.helpers
        all_shop: ->
            Docs.find
                model:'payment'


        current_subgroups: ->
            Docs.find 
                model:'group'
                parent_group_id:Meteor.user().current_group_id