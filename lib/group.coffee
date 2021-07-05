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
            Session.get('group_title_filter')
        @autorun => @subscribe 'group_facets',
            picked_group_tags.array()
            Session.get('group_title_filter')
    
    
    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'parent_group_from_child_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'child_groups_from_parent_id', Router.current().params.doc_id, ->
    


    Template.groups.events
        'click .add_group': ->
            new_id = Docs.insert 
                model:'group'
            Router.go "/group/#{new_id}/edit"    
        'click .pick_group_tag': -> picked_group_tags.push @title
        'click .unpick_group_tag': -> picked_group_tags.remove @valueOf()

                
            
    Template.groups.helpers
        picked_group_tags: -> picked_group_tags.array()
        current_group_title_filter: ->
            Session.get('group_title_filter')
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
        @autorun => Meteor.subscribe 'parent_group_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'group'


    Template.group_edit.helpers
        nonparent_groups: ->
            current_group = 
                Docs.findOne Router.current().params.doc_id
            if current_group and current_group.parent_group_id
                Docs.find
                    model:'group'
                    # _author_id:Meteor.userId()
                    _id:$nin:current_group.parent_group_ids
            else 
                Docs.find
                    model:'group'
                    _id:$ne:current_group._id
  
  
    Template.group_edit.events
        'click .delete_group':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/groups"
            
        'click .set_parent': ->
            Docs.update Router.current().params.doc_id, 
                $set: 
                    parent_group_id:@_id
                    
        'click .clear_parent_group': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $unset: 
                        parent_group_id:1
                $('body').toast(
                    showIcon: 'remove'
                    message: "#{@title} removed as parent"
                    # showProgress: 'bottom'
                    class: 'error'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
            , 600
            
                    
            
            
if Meteor.isServer
    Meteor.publish 'parent_group_from_child_id', (child_id)->
        group = Docs.findOne child_id
        Docs.find 
            model:'group'
            _id:group.parent_group_id
            
    Meteor.publish 'child_groups_from_parent_id', (parent_id)->
        group = Docs.findOne parent_id
        Docs.find 
            model:'group'
            parent_group_id:parent_id
            
            