if Meteor.isClient
    @picked_task_tags = new ReactiveArray []
    
    Router.route '/task/:doc_id', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'
    Router.route '/tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'tasks'
    
    Template.tasks.onCreated ->
        @autorun => @subscribe 'task_docs',
            picked_task_tags.array()
            Session.get('task_title_filter')

        @autorun => @subscribe 'task_facets',
            picked_task_tags.array()
            Session.get('task_title_filter')

    Template.tasks.events
        'click .add_task': ->
            new_id = Docs.insert 
                model:'task'
            Router.go "/task/#{new_id}/edit"    
        'click .pick_task_tag': -> picked_task_tags.push @title
        'click .unpick_task_tag': -> picked_task_tags.remove @valueOf()

                
            
    Template.tasks.helpers
        picked_task_tags: -> picked_task_tags.array()
    
        task_docs: ->
            Docs.find 
                model:'task'
                # group_id: Meteor.user().current_group_id
                
        task_tag_results: ->
            Results.find {
                model:'task_tag'
            }, sort:_timestamp:-1
  
                

            
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'child_groups_from_parent_id', Router.current().params.doc_id,->
 
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


    Template.task_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                task_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.task_view.helpers
        possible_locations: ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:task.location_ids
                
        task_work: ->
            Docs.find 
                model:'work'
                task_id:Router.current().params.doc_id
                
    Template.task_edit.helpers
        task_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids then 'blue' else 'basic'
            
                
    Template.task_edit.events
        'click .select_location': ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id
            
if Meteor.isServer
    Meteor.publish 'task_work', (task_id)->
        Docs.find   
            model:'work'
            task_id:task_id
    # Meteor.publish 'work_task', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'task'
    #         _id: work.task_id
            
            
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
                Router.go "/tasks"
            
    Template.task_edit.helpers
        all_shop: ->
            Docs.find
                model:'task'


        current_subgroups: ->
            Docs.find 
                model:'group'
                parent_group_id:Meteor.user().current_group_id