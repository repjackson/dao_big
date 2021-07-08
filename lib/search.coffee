if Meteor.isClient
    Router.route '/search', (->
        @layout 'layout'
        @render 'search'
        ), name:'search'

    Template.search.helpers
        current_search: ->
            Session.get('global_search')
            
    Template.search.events
        
        
        
        