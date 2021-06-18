if Meteor.isClient
    Router.route '/work', (->
        @layout 'layout'
        @render 'work'
        ), name:'work'
    Router.route '/user/:username/work', (->
        @layout 'user_layout'
        @render 'user_work'
        ), name:'user_work'
    Router.route '/work/:doc_id', (->
        @layout 'layout'
        @render 'work_view'
        ), name:'work_view'
    Router.route '/work/:doc_id/view', (->
        @layout 'layout'
        @render 'work_view'
        ), name:'work_view_long'
    Router.route '/product/:doc_id/work', (->
        @layout 'product_layout'
        @render 'product_work'
        ), name:'product_work'
    
    
    Template.work.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'work', ->
            
            
    Template.product_work.onCreated ->
        @autorun => Meteor.subscribe 'product_work', Router.current().params.doc_id, ->
    Template.user_work.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_work', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_work', Router.current().params.username, ->
            
    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.work_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    

    Template.work_view.helpers
        is_cook: -> Meteor.userId() in @cook_ids
        is_fav: -> Meteor.userId() in @favorite_user_ids
    Template.work_view.events
        'click .mark_cook': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: cook_ids:Meteor.userId()
            $('body').toast(
                showIcon: 'food'
                message: "marked cooked"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
        'click .unmark_cook': ->
            Docs.update Router.current().params.doc_id, 
                $pull: cook_ids:Meteor.userId()
       
        'click .mark_fav': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: favorite_user_ids:Meteor.userId()
            $('body').toast(
                showIcon: 'heart'
                message: "marked favorite"
                showProgress: 'bottom'
                class: 'error'
                # displayTime: 'auto',
                position: "bottom right"
            )
        'click .unmark_fav': ->
            Docs.update Router.current().params.doc_id, 
                $pull: favorite_user_ids:Meteor.userId()

    Template.work.events
        'click .add_work': ->
            new_id = Docs.insert 
                model:'work'
            Router.go "/work/#{new_id}/edit"    
    
    Template.product_work.events
        'click .add_work': ->
            new_id = Docs.insert 
                model:'work'
                product_id:Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
                
    Template.user_work.events
        'click .send_work': ->
            new_id = 
                Docs.insert 
                    model:'work'
            
            Router.go "/work/#{new_id}/edit"
            
            
        # 'click .edit_address': ->
        #     Session.set('editing_id',@_id)
        # 'click .remove_address': ->
        #     if confirm 'confirm delete?'
        #         Docs.remove @_id
        # 'click .add_address': ->
        #     new_id = 
        #         Docs.insert
        #             model:'address'
        #     Session.set('editing_id',new_id)
            
           
           
            
    Template.user_work.helpers
        sent_work: ()->
            Docs.find   
                model:'work'
                _author_username:Router.current().params.username
        received_work: ()->
            Docs.find   
                model:'work'
                recipient_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'user_received_work', (username)->
        Docs.find   
            model:'work'
            recipient_username:username
            
            
    Meteor.publish 'user_sent_work', (username)->
        Docs.find   
            model:'work'
            _author_username:username
    Meteor.publish 'product_work', (product_id)->
        Docs.find   
            model:'work'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/work/:doc_id/edit', (->
        @layout 'layout'
        @render 'work_edit'
        ), name:'work_edit'



    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.work_edit.events
        'click .send_work': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    work = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update work._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'work sent',
                        ''
                        'success'
                    Router.go "/work/#{@_id}/"
                    )
            )

        'click .delete_work':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/work"
            
    Template.work_edit.helpers
        all_shop: ->
            Docs.find
                model:'work'
