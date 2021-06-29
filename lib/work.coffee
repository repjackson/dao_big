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
    
    
    
    Template.work.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'work', ->
            
            
    Template.user_work.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_work', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_work', Router.current().params.username, ->
            
    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'model_docs', 'staff', ->

    Template.work_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'work_task', Router.current().params.doc_id, ->


    Template.work.helpers
        work_list: ->
            Docs.find {
                model:'work'
            }, sort:_timestamp:-1
        eric_total: ->
            Docs.find({
                model:'work'
                staff_id:'vRbbcxAXKY75m8ZTP'
            }).count()
        ryan_total: ->
            Docs.find({
                model:'work'
                staff_id:'wgj7J54mLMGdJ49dy'
            }).count()
    Template.work.events
        'click .add_work': ->
            new_id = Docs.insert 
                model:'work'
            Router.go "/work/#{new_id}/edit"    
      
        'click .add_task': ->
            new_id = Docs.insert 
                model:'task'
            Router.go "/task/#{new_id}/edit"    
    
                
    Template.work_edit.events
        'click .pick_staff': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    staff_id:@_id
                    staff_name: "#{@first_name} #{@last_name}"
                    staff_image_id: @image_id
        
        'click .pick_location': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    location_id:@_id
                    location_title: @title
                    location_image_id: @image_id
        
        
        
    Template.work_edit.helpers
        task_locations: ->
            work_doc = Docs.findOne(model:'task')
            Docs.find 
                model:'location'
                _id: $in: work_doc.location_ids
                
        porter_staff: ->
            Docs.find 
                model:'staff'
                
        staff_picker_class: ->
            work = Docs.findOne Router.current().params.doc_id
            if work.staff_id is @_id then 'active massive' else 'basic large'
            
        location_picker_class: ->
            work = Docs.findOne Router.current().params.doc_id
            if work.location_id is @_id then 'active massive' else 'basic large'
            
        
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
        @autorun => Meteor.subscribe 'work_task', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.work_edit.events
        # 'click .send_work': ->
        #     Swal.fire({
        #         title: 'confirm send card'
        #         text: "#{@amount} credits"
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             work = Docs.findOne Router.current().params.doc_id
        #             Meteor.users.update Meteor.userId(),
        #                 $inc:credit:-@amount
        #             Docs.update work._id,
        #                 $set:
        #                     sent:true
        #                     sent_timestamp:Date.now()
        #             Swal.fire(
        #                 'work sent',
        #                 ''
        #                 'success'
        #             Router.go "/work/#{@_id}/"
        #             )
        #     )

        'click .delete_work':->
            Swal.fire({
                title: "delete work entry?"
                text: "for #{@task_title}"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    Docs.remove @_id
                    Router.go "/porters"
            )            
    Template.work_edit.helpers
        all_shop: ->
            Docs.find
                model:'work'

if Meteor.isServer
    # Meteor.publish 'user_received_task', (username)->
    #     Docs.find   
    #         model:'task'
    #         recipient_username:username
            
    Meteor.publish 'work_task', (work_id)->
        work = Docs.findOne work_id
        Docs.find   
            model:'task'
            _id: work.task_id
