if Meteor.isClient
    Router.route '/task/:doc_id', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'
    
    Template.task.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task', ->
            
            
    Template.user_task.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_task', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_task', Router.current().params.username, ->
            
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
    


    Template.task_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                task_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
    Template.product_task.events
        'click .add_task': ->
            new_id = Docs.insert 
                model:'task'
                product_id:Router.current().params.doc_id
            Router.go "/task/#{new_id}/edit"    
                
    Template.user_task.events
        'click .send_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
            
            Router.go "/task/#{new_id}/edit"
            
            
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
            
           
           
            
    Template.user_task.helpers
        sent_task: ()->
            Docs.find   
                model:'task'
                _author_username:Router.current().params.username
        received_task: ()->
            Docs.find   
                model:'task'
                recipient_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'user_received_task', (username)->
        Docs.find   
            model:'task'
            recipient_username:username
            
    Meteor.publish 'work_task', (work_id)->
        work = Docs.findOne work_id
        Docs.find   
            model:'task'
            _id: work.task_id
            
            
    Meteor.publish 'user_sent_task', (username)->
        Docs.find   
            model:'task'
            _author_username:username
    Meteor.publish 'product_task', (product_id)->
        Docs.find   
            model:'task'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'



    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.task_edit.events
        'click .send_task': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    task = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update task._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'task sent',
                        ''
                        'success'
                    Router.go "/task/#{@_id}/"
                    )
            )

        'click .delete_task':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/task"
            
    Template.task_edit.helpers
        all_shop: ->
            Docs.find
                model:'task'
