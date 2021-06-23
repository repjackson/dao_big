if Meteor.isClient
    Router.route '/staff/:staff_firstname', (->
        @layout 'layout'
        @render 'staff_view'
        ), name:'staff_name_view'
    Router.route '/staff', (->
        @layout 'layout'
        @render 'staff'
        ), name:'staff'
    
            
    Template.staff.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'staff', ->
    
    Template.staff_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'staff_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'staff_by_firstname', Router.current().params.staff_firstname, ->
    
    
    Template.staff_view.onCreated ->
        @autorun => Meteor.subscribe 'staff_by_firstname', Router.current().params.staff_firstname, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'staff_work', Router.current().params.doc_id, ->
    


    Template.staff.events
        'click .add_staff': ->
            new_id = Docs.insert 
                model:'staff'
            Router.go "/staff/#{new_id}/edit"    
    
                
           
            
    Template.staff.helpers
        staff_docs: ->
            Docs.find 
                model:'staff'
               
               
    Template.staff_view.helpers
        current_staff: ->
            Docs.findOne
                model:'staff'
                
        
if Meteor.isServer
    Meteor.publish 'work_staff', (work_id)->
        work = Docs.findOne work_id
        Docs.find   
            model:'staff'
            _id: work.staff_id
            
    Meteor.publish 'staff_by_firstname', (first_name)->
        Docs.find   
            model:'staff'
            first_name: first_name
            
            
    Meteor.publish 'user_sent_staff', (username)->
        Docs.find   
            model:'staff'
            _author_username:username
    Meteor.publish 'product_staff', (product_id)->
        Docs.find   
            model:'staff'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/staff/:doc_id/edit', (->
        @layout 'layout'
        @render 'staff_edit'
        ), name:'staff_edit'



    Template.staff_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.staff_edit.events
        'click .send_staff': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    staff = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update staff._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'staff sent',
                        ''
                        'success'
                    Router.go "/staff/#{@_id}/"
                    )
            )

        'click .delete_staff':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/staff"
            