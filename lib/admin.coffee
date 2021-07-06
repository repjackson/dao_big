if Meteor.isClient
    @picked_post_tags = new ReactiveArray []
    
    Router.route '/admin', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'
            
    Template.admin.onCreated ->
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
    


    Template.admin.events
        'click .add_post': ->
            new_id = Docs.insert 
                model:'post'
            Router.go "/post/#{new_id}/edit"    
        'click .pick_post_tag': -> picked_post_tags.push @title
        'click .unpick_post_tag': -> picked_post_tags.remove @valueOf()

                
            
    Template.admin.helpers
        picked_post_tags: -> picked_post_tags.array()
    
        post_docs: ->
            Docs.find 
                model:'post'
        post_tag_results: ->
            Results.find {
                model:'post_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'user_sent_post', (username)->
        Docs.find   
            model:'post'
            _author_username:username
    Meteor.publish 'product_post', (product_id)->
        Docs.find   
            model:'post'
            product_id:product_id
            