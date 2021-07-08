if Meteor.isClient
    Router.route '/search', (->
        @layout 'layout'
        @render 'search'
        ), name:'search'


    Template.search.onCreated ->
        @autorun => Meteor.subscribe 'global_search', Session.get('global_search'), ->


    Template.search.helpers
        current_search: ->
            Session.get('global_search')
            
        search_results: ->
            search = Session.get('global_search')
            Docs.find 
                title: {$regex:"#{search}", $options: 'i'}

                
                
    Template.search.events
        
        
if Meteor.isServer
    Meteor.publish 'global_search', (search)->
        Docs.find(
            {
                title: {$regex:"#{search}", $options: 'i'}
            }, limit:20
        )
        
        