if Meteor.isClient
    Router.route '/porters', (->
        @layout 'layout'
        @render 'porters'
        ), name:'porters'
    
    Template.task.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task', ->
            
            
    Template.user_task.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_task', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_task', Router.current().params.username, ->
            
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
