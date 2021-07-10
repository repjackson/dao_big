if Meteor.isClient
    @picked_post_tags = new ReactiveArray []
    
    Router.route '/post/:doc_id', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
        
    Template.post_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id

            
    Template.posts.onCreated ->
        @autorun => @subscribe 'post_docs',
            picked_post_tags.array()
            Session.get('post_title_filter')

        @autorun => @subscribe 'post_facets',
            picked_post_tags.array()
            Session.get('post_title_filter')

    
    
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'post_work', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'model_docs', 'post', ->
    


    Template.posts.events
        'click .add_post': ->
            new_id = Docs.insert 
                model:'post'
            Router.go "/post/#{new_id}/edit"    
        'click .pick_post_tag': -> picked_post_tags.push @title
        'click .unpick_post_tag': -> picked_post_tags.remove @valueOf()

                
            
    Template.posts.helpers
        picked_post_tags: -> picked_post_tags.array()
    
        post_docs: ->
            Docs.find 
                model:'post'
        post_tag_results: ->
            Results.find {
                model:'post_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'product_post', (product_id)->
        Docs.find   
            model:'post'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'



    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_posts', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'post'


    Template.post_edit.helpers
        nonparent_posts: ->
            current_post = 
                Docs.findOne Router.current().params.doc_id
            if current_post
                Docs.find
                    model:'post'
                    # _author_id:Meteor.userId()
                    _id:$nin:current_post.parent_post_ids
  
  
    Template.post_edit.events
        'click .delete_post':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/posts"
            
        'click .add_parent': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    parent_post_ids:@_id
                    
        'click .remove_parent_post': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 1000)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $pull: 
                        parent_post_ids:@_id
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
    Meteor.publish 'parent_posts', (post_id)->
        post = Docs.findOne post_id
        Docs.find 
            model:'post'
            _id:$in:post.parent_ids