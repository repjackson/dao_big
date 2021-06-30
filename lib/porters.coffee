if Meteor.isClient
    Router.route '/porters', (->
        @layout 'layout'
        @render 'porters'
        ), name:'porters'
    
    Template.porters.onCreated ->
        @autorun => Meteor.subscribe 'porter_tasks', ->
            
    Template.porters.helpers
        porter_tasks: ->
            Docs.find 
                model:'task'
                station:'porters'
    
    Template.porters.events
        'click .add_porter_task':->
            new_id = 
                Docs.insert
                    model:'task'
                    station:'porters'
            Router.go "/task/#{new_id}/edit"
    
    
        'click .log_work':->
            # task = Docs.findOne Router.current().params.doc_id
            if Meteor.user()
                new_object = {
                    model:'work'
                    station:'porters'
                    task_id:@_id
                    task_title:@title
                    task_image_id:@image_id
                    task_points: @points
                }
                if @location_ids.length is 1
                    new_object.location_id = @location_ids[0]
                new_id = 
                    Docs.insert new_object
                Docs.update @_id,
                    $inc: work_count:1
                Router.go "/work/#{new_id}/edit"
    
    
                    
                            
            
            
            
if Meteor.isServer
    Meteor.publish 'porter_tasks', ->
        Docs.find 
            model:'task'
            station:'porters'
            