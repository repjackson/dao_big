if Meteor.isClient
    @picked_unit_tags = new ReactiveArray []
    
    Router.route '/unit/:doc_id', (->
        @layout 'layout'
        @render 'unit_view'
        ), name:'unit_view'
    Router.route '/units', (->
        @layout 'layout'
        @render 'units'
        ), name:'units'
        
    Template.unit_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        @autorun => @subscribe 'unit_children', 'repair', Router.current().params.doc_id
        @autorun => @subscribe 'unit_children', 'task', Router.current().params.doc_id
        @autorun => @subscribe 'unit_children', 'tenant', Router.current().params.doc_id

    Template.unit_view.events
        'click .apply_now': ->
            unit = Docs.findOne Router.current().params.doc_id 
            new_id = 
                Docs.insert 
                    model:'application'
                    unit_id: Router.current().params.doc_id 
                    unit_title:unit.title
                    parent_id: Router.current().params.doc_id 
            Router.go "/application/#{new_id}/edit"
    Template.units.onCreated ->
        @autorun => @subscribe 'unit_docs',
            picked_unit_tags.array()
            Session.get('unit_title_filter')
            Session.get('view_owned')

        @autorun => @subscribe 'unit_facets',
            picked_unit_tags.array()
            Session.get('unit_title_filter')
            Session.get('view_owned')

    
    
    Template.unit_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'unit_work', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'model_docs', 'unit', ->
    Template.unit_view.helpers

    


    Template.units.events
        'click .add_unit': ->
            new_id = Docs.insert 
                model:'unit'
            Router.go "/unit/#{new_id}/edit"    
        'click .pick_unit_tag': -> picked_unit_tags.push @title
        'click .unpick_unit_tag': -> picked_unit_tags.remove @valueOf()

                
            
    Template.units.helpers
        picked_unit_tags: -> picked_unit_tags.array()
    
        unit_docs: ->
            Docs.find 
                model:'unit'
        unit_tag_results: ->
            Results.find {
                model:'unit_tag'
            }, sort:_timestamp:-1
  
          
          
          
    Template.unit_children.helpers
        model_children: ->
            Docs.find 
                model:@model
                unit_id:Router.current().params.doc_id
                
        
if Meteor.isServer
    Meteor.publish 'product_unit', (product_id)->
        Docs.find   
            model:'unit'
            product_id:product_id
            
    Meteor.publish 'unit_children', (model, unit_id)->
        Docs.find   
            model:model
            unit_id:unit_id
            
    Meteor.publish 'unit_docs', (picked_tags, title_query, view_owned)->
        match = {model:'unit'}
        if view_owned
            match.owned = true
        Docs.find match
            # model:'unit'
            # product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/unit/:doc_id/edit', (->
        @layout 'layout'
        @render 'unit_edit'
        ), name:'unit_edit'



    Template.unit_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_units', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'unit'


    Template.unit_edit.helpers
        nonparent_units: ->
            current_unit = 
                Docs.findOne Router.current().params.doc_id
            if current_unit
                Docs.find
                    model:'unit'
                    # _author_id:Meteor.userId()
                    _id:$nin:current_unit.parent_unit_ids
  
  
    Template.unit_edit.events
        'click .delete_unit':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/units"
            
        'click .add_parent': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    parent_unit_ids:@_id
                    
        'click .remove_parent_unit': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 1000)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $pull: 
                        parent_unit_ids:@_id
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
    Meteor.publish 'parent_units', (unit_id)->
        unit = Docs.findOne unit_id
        Docs.find 
            model:'unit'
            _id:$in:unit.parent_ids