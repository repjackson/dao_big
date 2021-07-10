if Meteor.isClient
    @picked_post_tags = new ReactiveArray []
    
    Router.route '/admin', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'
            
    Template.admin_footer.onCreated ->
        @autorun => @subscribe 'top_groups', ->
        @autorun => @subscribe 'admin_user_switcher', ->
        @autorun => @subscribe 'current_group_members', ->
        
        
        
    Template.admin.onCreated ->
        @autorun => @subscribe 'admin_tasks',
            picked_post_tags.array()
            Session.get('post_title_filter')
        @autorun => @subscribe 'admin_notes',
            picked_post_tags.array()
            Session.get('post_title_filter')

        # @autorun => @subscribe 'post_facets',
        #     picked_post_tags.array()
        #     Session.get('post_title_filter')

    
    
    # Template.post_view.onCreated ->
    #     @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    #     @autorun => Meteor.subscribe 'post_work', Router.current().params.doc_id, ->
    #     # @autorun => Meteor.subscribe 'model_docs', 'post', ->
    


    Template.admin.events
        'click .add_post': ->
            new_id = Docs.insert 
                model:'post'
            Router.go "/post/#{new_id}/edit"    
        'click .pick_post_tag': -> picked_post_tags.push @title
        'click .unpick_post_tag': -> picked_post_tags.remove @valueOf()

                
            
    Template.admin_footer.events
        'click .switch_to_group': ->
            Meteor.users.update Meteor.userId(),
                $set:
                    current_group_id:@_id
                    
    
    Template.admin_footer.helpers
        group_switcher_class: ->
            if Meteor.user().current_group_id and @_id is Meteor.user().current_group_id
                'black'
            else
                'basic'
            
        top_groups: ->
            Docs.find   
                model:'group'
                parent_group_id:$exists:false
                # _author_username:username
                
                
        current_group_members: ->
            Meteor.users.find   
                membership_group_ids:$in:[Meteor.user().current_group_id]
                
                
                
    Template.admin.helpers
        picked_post_tags: -> picked_post_tags.array()
    
        admin_tasks: ->
            Docs.find 
                model:'task'
        admin_notes: ->
            Docs.find
                model:'note'
                
        
if Meteor.isServer
    Meteor.publish 'current_group_members', ()->
        Meteor.users.find   
            membership_group_ids:$in:[Meteor.user().current_group_id]
        
    Meteor.publish 'top_groups', ()->
        Docs.find   
            model:'group'
            parent_group_id:$exists:false
            # _author_username:username
    Meteor.publish 'admin_notes', (username)->
        Docs.find   
            model:'note'
            admin:true
            # _author_username:username
    Meteor.publish 'admin_tasks', (product_id)->
        Docs.find   
            model:'task'
            admin:true            