if Meteor.isClient
    @picked_repair_tags = new ReactiveArray []
    
    Router.route '/repair/:doc_id', (->
        @layout 'layout'
        @render 'repair_view'
        ), name:'repair_view'
    Router.route '/repairs', (->
        @layout 'layout'
        @render 'repairs'
        ), name:'repairs'
        
    Template.repair_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        @autorun => @subscribe 'repair_children', 'repair', Router.current().params.doc_id
        @autorun => @subscribe 'repair_children', 'task', Router.current().params.doc_id
        @autorun => @subscribe 'repair_children', 'tenant', Router.current().params.doc_id

            
    Template.repairs.onCreated ->
        @autorun => @subscribe 'repair_docs',
            picked_repair_tags.array()
            Session.get('repair_title_filter')

        @autorun => @subscribe 'repair_facets',
            picked_repair_tags.array()
            Session.get('repair_title_filter')

    
    
    Template.repair_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'repair_work', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'model_docs', 'repair', ->
    


    Template.repairs.events
        'click .add_repair': ->
            new_id = Docs.insert 
                model:'repair'
            Router.go "/repair/#{new_id}/edit"    
        'click .pick_repair_tag': -> picked_repair_tags.push @title
        'click .unpick_repair_tag': -> picked_repair_tags.remove @valueOf()

                
            
    Template.repairs.helpers
        picked_repair_tags: -> picked_repair_tags.array()
    
        repair_docs: ->
            Docs.find 
                model:'repair'
        repair_tag_results: ->
            Results.find {
                model:'repair_tag'
            }, sort:_timestamp:-1
  
          
          
          
    Template.repair_children.helpers
        model_children: ->
            Docs.find 
                model:@model
                repair_id:Router.current().params.doc_id
                
        
if Meteor.isServer
    Meteor.publish 'product_repair', (product_id)->
        Docs.find   
            model:'repair'
            product_id:product_id
            
    Meteor.publish 'repair_children', (model, repair_id)->
        Docs.find   
            model:model
            repair_id:repair_id
            
    Meteor.publish 'repair_docs', (product_id)->
        Docs.find   
            model:'repair'
            # product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/repair/:doc_id/edit', (->
        @layout 'layout'
        @render 'repair_edit'
        ), name:'repair_edit'



    Template.repair_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_repairs', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'repair'


    Template.repair_edit.helpers
        nonparent_repairs: ->
            current_repair = 
                Docs.findOne Router.current().params.doc_id
            if current_repair
                Docs.find
                    model:'repair'
                    # _author_id:Meteor.userId()
                    _id:$nin:current_repair.parent_repair_ids
  
  
    Template.repair_edit.events
        'click .delete_repair':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/repairs"
            
        'click .add_parent': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    parent_repair_ids:@_id
                    
        'click .remove_parent_repair': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 1000)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $pull: 
                        parent_repair_ids:@_id
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
    Meteor.publish 'parent_repairs', (repair_id)->
        repair = Docs.findOne repair_id
        Docs.find 
            model:'repair'
            _id:$in:repair.parent_ids