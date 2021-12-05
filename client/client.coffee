@picked_tags = new ReactiveArray []


# Meteor.startup ->
#     Status.setTemplate('semantic_ui')

Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0


Template.home.onCreated ->
    @autorun => @subscribe 'model_docs','stats_doc', ->
Template.home.onCreated ->
    @autorun => @subscribe 'model_docs','page', ->
Template.direct_doc.helpers   
    stats_doc: ->
        Docs.findOne 
            model:'page'
            key:@key
            
Template.direct_doc.events  
    'click .create_doc': ->
        Docs.insert 
            model:'page'
            key:@key
            
Template.home.events
    'click .refresh_stats': ->
        Meteor.call 'refresh_stats', ->



Template.direct_doc.helpers
    doc: ->
        Docs.findOne 
            model:'page'
            key:@

$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

        
Template.body.events
    'click .zoom_in_card': (e,t)->
        $(e.currentTarget).closest('.column').transition('drop', 500)
    'click .zoom_out': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale', 500)
    'click .fly_up': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly up', 500)
    'click .fly_down': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly down', 500)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
    'click .fly_left': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly left', 500)


    "click a:not('.no_blink')": ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.healthclub.events
    # 'click .button': ->
    #     $('.global_container')
    #     .transition('fade out', 5000)
    #     .transition('fade in', 5000)

Template.layout.helpers
    logging_in: -> Meteor.loggingIn()
    
    
Template.nav.events
    # 'mouseenter .item': (e,t)->
    #     $(e.currentTarget).closest('.item').transition('pulse')
    # 'click .menu_dropdown': ->
        # $('.menu_dropdown').dropdown(
            # on:'hover'
        # )

    'click .logout': ->
        Session.set 'logging_out', true
        Meteor.logout ->
            Session.set 'logging_out', false
            # Router.go '/'

Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    # @autorun -> Meteor.subscribe 'users'
    # @autorun -> Meteor.subscribe 'users_by_role','staff'
    # @autorun -> Meteor.subscribe 'unread_messages'


Router.route '/', (->
    @render 'home'
    ), name:'home'