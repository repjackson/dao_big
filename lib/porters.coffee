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
            new_id = 
                Docs.insert
                    model:'work'
                    task_id:@_id
                    station:'porters'
                    task_name:@title
            Router.go "/work/#{new_id}/edit"
    
    
                    
                            
            
            
            
if Meteor.isServer
    Meteor.publish 'porter_tasks', ->
        Docs.find 
            model:'task'
            station:'porters'
            