if Meteor.isClient
    @picked_group_tags = new ReactiveArray []
    
    Router.route '/group/:doc_id', (->
        @layout 'layout'
        @render 'group_view'
        ), name:'group_view'
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    
            
    Template.groups.onCreated ->
        @autorun => @subscribe 'group_docs',
            picked_group_tags.array()
        @autorun => @subscribe 'group_facets',
            picked_group_tags.array()
    
    
    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'group', ->
    


    Template.groups.events
        'click .add_group': ->
            new_id = Docs.insert 
                model:'group'
            Router.go "/group/#{new_id}/edit"    
        'click .pick_group_tag': -> picked_group_tags.push @title
        'click .unpick_group_tag': -> picked_group_tags.remove @valueOf()

                
            
    Template.groups.helpers
        picked_group_tags: -> picked_group_tags.array()
    
        group_docs: ->
            Docs.find 
                model:'group'
        group_tag_results: ->
            Results.find {
                model:'group_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'user_sent_group', (username)->
        Docs.find   
            model:'group'
            _author_username:username
    Meteor.publish 'product_group', (product_id)->
        Docs.find   
            model:'group'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/group/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_edit'
        ), name:'group_edit'



    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_groups', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'group'


    Template.group_edit.helpers
        nonparent_groups: ->
            current_group = 
                Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'group'
                _author_id:Meteor.userId()
                _id:$nin:current_group.parent_group_ids
  
  
    Template.group_edit.events
        'click .delete_group':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/groups"
            
        'click .add_parent': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    parent_group_ids:@_id
                    
        'click .remove_parent_group': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 1000)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $pull: 
                        parent_group_ids:@_id
                $('body').toast(
                    showIcon: 'remove'
                    message: "#{@title} removed as parent"
                    # showProgress: 'bottom'
                    class: 'error'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
            , 1000
            
                    
            
            
if Meteor.isServer
    Meteor.publish 'parent_groups', (group_id)->
        group = Docs.findOne group_id
        Docs.find 
            model:'group'
            _id:$in:group.parent_ids