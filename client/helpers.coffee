Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

Template.registerHelper 'parent', () -> Template.parentData()
Template.registerHelper 'parent_doc', () ->
    Docs.findOne @parent_id
    # Template.parentData()
Template.registerHelper 'rental', () ->
    Docs.findOne @rental_id
    # Template.parentData()
Template.registerHelper 'included_ingredients', () ->
    Docs.find
        model:'ingredient'
        _id: $in:@ingredient_ids

Template.registerHelper 'ingredient_products', () ->
    Docs.find   
        model:'product'
        ingredient_ids:$in:[@_id]


Template.registerHelper 'current_group', () ->
    # if Meteor.user() and Meteor.user().current_group_id
    if Meteor.user()
        Docs.findOne Meteor.user().current_group_id
        
    # Template.parentData()
Template.registerHelper 'work_task', () ->
    Docs.findOne @task_id
    # Template.parentData()


Template.registerHelper 'is_editing_this', (input)-> 
    Session.equals('editing_id', @_id)

Template.registerHelper 'lowered', (input)-> input.toLowerCase()

Template.registerHelper 'pathname_root', () ->
    window.location.pathname.split('/')[1]
Template.registerHelper 'current_route', () ->
    # console.log window.location.pathname.split('/')[1]
    Router.current().location.get().path
    
Template.registerHelper 'active_path', (metric) ->
    false

Template.registerHelper 'member_groups', (id)->
    Docs.find 
        model:'group'
        _id:$in:@membership_group_ids
    
    
Template.registerHelper 'child_groups', (id)->
    # current_group = 
        # Docs.findOne Router.current().params.doc_id
        # Docs.findOne Router.
    Docs.find
        model:'group'
        # parent_group_ids:$in:[current_group._id]
        parent_group_id:@_id
    
Template.registerHelper 'sibling_groups', (id)->
    # current_group = 
        # Docs.findOne Router.current().params.doc_id
        # Docs.findOne Router.
    Docs.find
        model:'group'
        # parent_group_ids:$in:[current_group._id]
        has_parent_group:true
        parent_group_id:@parent_group_id
        _id:$ne:@_id
    
    
    
Template.registerHelper 'parent_group', ()->
    Docs.findOne
        _id:@parent_group_id
        model:'group'
Template.registerHelper 'group_doc', ()->
    Docs.findOne
        _id:@group_id
        model:'group'

Template.registerHelper 'user_from_id', (id)->
    Meteor.users.findOne id
    
Template.registerHelper 'kve', (key,value) ->
    @["#{key}"] is value
    
Template.registerHelper 'gs', () ->
    Docs.findOne
        model:'global_settings'
Template.registerHelper 'display_mode', () -> Session.get('display_mode',true)
Template.registerHelper 'is_loading', () -> Session.get 'loading'
Template.registerHelper 'dev', () -> Meteor.isDevelopment
Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input) -> moment(input).format("dd, MMMM Do h:mm a")
Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'fixed', (input) ->
    if input
        input.toFixed(2)
Template.registerHelper 'int', (input) -> 
    if input
        input.toFixed(0)
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()


Template.registerHelper 'group_products', (input) ->
    Docs.find 
        model:'product'
        group_id: @_id


Template.registerHelper 'logging_out', () -> Session.get 'logging_out'

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'


Template.registerHelper 'session_is', (key, value)->
    Session.equals(key, value)

Template.registerHelper 'key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] is value

Template.registerHelper 'in_role', (role)->
    if Meteor.user()
        Meteor.user().roles and role in Meteor.user().roles


Template.registerHelper 'is_requester', ->
    if Meteor.user()
        @_author_username is Meteor.user().username
Template.registerHelper 'is_requested', -> @status is 'requested'
Template.registerHelper 'is_processing', -> @status is 'processing'
Template.registerHelper 'is_delivered', -> @status is 'delivered'



Template.registerHelper 'is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    key is value

Template.registerHelper 'parent_key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] is value



# Template.registerHelper 'parent_template', () -> Template.parentData()
    # Session.get 'displaying_profile'

# Template.registerHelper 'checking_in_doc', () ->
#     Docs.findOne
#         model:'healthclub_session'
#         current:true
#      # Session.get('session_document')

# Template.registerHelper 'current_session_doc', () ->
#         Docs.findOne
#             model:'healthclub_session'
#             current:true



# Template.registerHelper 'checkin_guest_docs', () ->
#     Docs.findOne Router.current().params.doc_id
#     session_document = Docs.findOne Router.current().params.doc_id
#     # console.log session_document.guest_ids
#     Docs.find
#         _id:$in:session_document.guest_ids


Template.registerHelper '_author', () -> Meteor.users.findOne @_author_id
Template.registerHelper 'is_text', () ->
    # console.log @field_type
    @field_type is 'text'

Template.registerHelper 'template_parent', () ->
    # console.log Template.parentData()
    Template.parentData()

Template.registerHelper 'fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        match = {}
        # if Meteor.user()
        #     match.view_roles = $in:Meteor.user().roles
        match.model = 'field'
        match.parent_id = model._id
        # console.log model
        cur = Docs.find match,
            sort:rank:1
        # console.log cur.fetch()
        cur

Template.registerHelper 'edit_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            edit_roles:$in:Meteor.user().roles
        }, sort:rank:1

Template.registerHelper 'sortable_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            sortable:true
        }, sort:rank:1


Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'current_model', (input) ->
    Docs.findOne
        model:'model'
        slug: Router.current().params.model_slug

Template.registerHelper 'in_list', (key) ->
    if Meteor.userId()
        if Meteor.userId() in @["#{key}"] then true else false

Template.registerHelper 'is_eric', () -> if Meteor.userId() and Meteor.userId() in ['ytjpFxiwnWaJELZEd','rDqxdcTBTszjeMh9T'] then true else false

Template.registerHelper 'current_user', () ->  Meteor.users.findOne username:Router.current().params.username
Template.registerHelper 'is_current_user', () ->
    if Meteor.user()
        if Meteor.user().username is Router.current().params.username
            true
        else
            if Meteor.user().roles and 'dev' in Meteor.user().roles
                true
            else
                false
    else 
        false
            
Template.registerHelper 'view_template', -> "#{@field_type}_view"
Template.registerHelper 'edit_template', -> "#{@field_type}_edit"
Template.registerHelper 'is_model', -> @model is 'model'


# Template.body.events
#     'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_editing', () -> Session.equals 'editing_id', @_id
Template.registerHelper 'editing_doc', () ->
    Docs.findOne Session.get('editing_id')

Template.registerHelper 'can_edit', () ->
    if Meteor.user()
        Meteor.userId() is @_author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'current_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    user = Meteor.users.findOne Router.current().params.doc_id
    # console.log doc
    # console.log user
    if doc then doc else if user then user


Template.registerHelper 'user_from_username_param', () ->
    found = Meteor.users.findOne username:Router.current().params.username
    # console.log found
    found
Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5
        if parent5._id
            parent = Template.parentData(5)
    else if parent6
        if parent6._id
            parent = Template.parentData(6)
    if parent
        parent["#{@key}"]


Template.registerHelper 'sorted_field_values', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5._id
        parent = Template.parentData(5)
    else if parent6._id
        parent = Template.parentData(6)
    if parent
        _.sortBy parent["#{@key}"], 'number'


Template.registerHelper 'in_dev', () -> Meteor.isDevelopment

Template.registerHelper 'calculated_size', (metric) ->
    # console.log metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log whole

    if whole is 2 then 'f2'
    else if whole is 3 then 'f3'
    else if whole is 4 then 'f4'
    else if whole is 5 then 'f5'
    else if whole is 6 then 'f6'
    else if whole is 7 then 'f7'
    else if whole is 8 then 'f8'
    else if whole is 9 then 'f9'
    else if whole is 10 then 'f10'



Template.registerHelper 'in_dev', () -> Meteor.isDevelopment


Template.registerHelper 'model_docs_helper', (model) ->
    # console.log model
    Docs.find 
        model:model
        group_id = Meteor.user().current_group_id
        
Template.registerHelper 'subs_ready', () -> 
    Template.instance().subscriptionsReady()

Template.registerHelper 'order_things',-> 
    Docs.find 
        model:'thing'
        order_id:@_id
Template.registerHelper 'product_doc',-> 
    # console.log @
    # console.log 'product doc'
    Docs.findOne
        model:'product'
        _id:@product_id

# Template.registerHelper 'order_count',-> Counts.get('order_count')
# Template.registerHelper 'product_count',-> Counts.get('product_count')
# Template.registerHelper 'ingredient_count',-> Counts.get('ingredient_count')
# Template.registerHelper 'subscription_count',-> Counts.get('subscription_count')
# Template.registerHelper 'source_count',-> Counts.get('source_count')
# Template.registerHelper 'giftcard_count',-> Counts.get('giftcard_count')
# Template.registerHelper 'user_count',-> Counts.get('user_count')
# Template.registerHelper 'staff_count',-> Counts.get('staff_count')
# Template.registerHelper 'customer_count',-> Counts.get('customer_count')


# Template.registerHelper 'cart_subtotal', () -> 
#     store_session_document = 
#         Docs.findOne 
#             model:'store_session'
#     if store_session_document.cart_product_ids
#         subtotal = 0
#         for product in Docs.find(_id:$in:store_session_document.cart_product_ids).fetch()
#             if product.price_usd
#                 subtotal += product.price_usd
#                 # console.log 'product', product
#         subtotal
    
Template.registerHelper 'my_cart_subtotal', () ->
    
    subtotal = 0
    for item in Docs.find(model:'thing',_author_id:Meteor.userId(),status:'cart').fetch()
        # product = Docs.findOne(item.product_id)
        # console.log product
        subtotal += item.product_price
        # if product
        #     if product.price_usd
        # if product.price_usd
        #     console.log product.price_usd
            # console.log 'product', product
    # console.log subtotal
    subtotal.toFixed(2)
    


Template.registerHelper 'commafy', (num)-> if num then num.toLocaleString()

    
Template.registerHelper 'trunc', (input) ->
    if input
        input[0..300]
   
   
Template.registerHelper 'emotion_avg', (metric) -> results.findOne(model:'emotion_avg')
Template.registerHelper 'skve', (key,val) -> 
    Session.equals(key,val)

Template.registerHelper 'calculated_size', (metric) ->
    # whole = parseInt(@["#{metric}"]*10)
    whole = parseInt(metric*10)
    switch whole
        when 0 then 'f5'
        when 1 then 'f6'
        when 2 then 'f7'
        when 3 then 'f8'
        when 4 then 'f9'
        when 5 then 'f10'
        when 6 then 'f11'
        when 7 then 'f12'
        when 8 then 'f13'
        when 9 then 'f14'
        when 10 then 'f15'
        
        
        
        
Template.registerHelper 'abs_percent', (num) -> 
    # console.l/og Math.abs(num*100)
    parseInt(Math.abs(num*100))
