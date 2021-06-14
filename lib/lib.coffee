@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Rental_tags = new Meteor.Collection 'rental_tags'

@Ingredients = new Meteor.Collection 'ingredients'


Docs.before.insert (userId, doc)->
    doc._author_id = Meteor.userId()
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    doc._author_id = Meteor.userId()
    if Meteor.user()
        doc._author_username = Meteor.user().username
    doc.app = 'pes'
    # doc.points = 0
    # doc.downvoters = []
    # doc.upvoters = []
    return

if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret




# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @_author_id
    cook: -> Meteor.users.findOne @cook_user_id

    when: -> moment(@_timestamp).fromNow()
    ten_tags: -> if @tags then @tags[..10]
    five_tags: -> if @tags then @tags[..4]
    three_tags: -> if @tags then @tags[..2]
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    from_user: ->
        if @from_user_id
            Meteor.users.findOne @from_user_id
    to_user: ->
        if @to_user_id
            Meteor.users.findOne @to_user_id


    food_orders: ->
        # if @order_ids
        Docs.find
            food_id:@_id
            model:'order'
        # else
        #     []
    order_food: ->
        Docs.findOne
            model:'food'
            _id:@food_id

    order_total_transaction_amount: ->
        @serving_purchase_price+@cook_tip


    order: ->
        Docs.findOne
            model:'order'
            _id:@order_id



    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters


Meteor.users.helpers
    name: ->
        if @nickname
            "#{@nickname}"
        else if @first_name and @last_name
            "#{@first_name} #{@last_name}"
        else
            "#{@username}"