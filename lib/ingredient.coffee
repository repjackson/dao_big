if Meteor.isClient
    Router.route '/ingredient/:doc_id', (->
        @layout 'layout'
        @render 'ingredient_view'
        ), name:'ingredient_view'
    Router.route '/ingredients', (->
        @layout 'layout'
        @render 'ingredients'
        ), name:'ingredients'
    
    Template.ingredients.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'ingredient', ->
            
            
    
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'ingredient_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'ingredient_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'products_from_ingredient_id', Router.current().params.doc_id, ->
    

    Template.ingredients.helpers
        ingredient_docs: ->
            Docs.find 
                model:'ingredient'
                
                
    Template.ingredients.events
        'click .add_ingredient': ->
            new_id = 
                Docs.insert 
                    model:'ingredient'
            Router.go "/ingredient/#{new_id}/edit"

    Template.ingredient_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                ingredient_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.ingredient_view.helpers
        ingredient_work: ->
            Docs.find   
                model:'work'
                ingredient_id:Router.current().params.doc_id

        possible_locations: ->
            ingredient = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:ingredient.location_ids
    Template.ingredient_edit.helpers
        ingredient_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            ingredient = Docs.findOne Router.current().params.doc_id
            if ingredient.location_ids and @_id in ingredient.location_ids then 'blue' else 'basic'
            
                
    Template.ingredient_edit.events
        'click .select_location': ->
            ingredient = Docs.findOne Router.current().params.doc_id
            if ingredient.location_ids and @_id in ingredient.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id
            
            
if Meteor.isServer
    Meteor.publish 'ingredient_products', (ingredient_id)->
        Docs.find   
            model:'product'
            ingredient_ids:$in:[ingredient_id]
            
    Meteor.publish 'products_from_ingredient_id', (ingredient_id)->
        ingredient = Docs.findOne ingredient_id
        Docs.find   
            model:'product'
            ingredient_ids:$in:[ingredient_id]
            
    # Meteor.publish 'work_ingredient', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'ingredient'
    #         _id: work.ingredient_id
            
            
    Meteor.publish 'user_liked_ingredients', (username)->
        Docs.find   
            model:'ingredient'
            _id:$in:Meteor.user().liked_ids
            
            
            
if Meteor.isClient
    Router.route '/ingredient/:doc_id/edit', (->
        @layout 'layout'
        @render 'ingredient_edit'
        ), name:'ingredient_edit'



    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.ingredient_edit.events
        'click .delete_ingredient':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/ingredients"
            
    Template.ingredient_edit.helpers
        all_shop: ->
            Docs.find
                model:'ingredient'
