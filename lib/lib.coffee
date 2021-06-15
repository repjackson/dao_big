@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'


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
    when: -> moment(@_timestamp).fromNow()
    
    
Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'requests'
    loadingTemplate: 'splash'
    trackPageView: false

# force_loggedin =  ()->
#     if !Meteor.userId()
#         @render 'login'
#     else
#         @next()

# Router.onBeforeAction(force_loggedin, {
#   # only: ['admin']
#   # except: ['register', 'forgot_password','reset_password','front','delta','doc_view','verify-email']
#   except: [
#     'food'
#     'register'
#     'users'
#     'services'
#     'service_view'
#     'products'
#     'product_view'
#     'rentals'
#     'rental_view'
#     'home'
#     'forgot_password'
#     'reset_password'
#     'user_orders'
#     'user_food'
#     'user_finance'
#     'user_dashboard'
#     'verify-email'
#     'food_view'
#   ]
# });


# Router.route('enroll', {
#     path: '/enroll-account/:token'
#     template: 'reset_password'
#     onBeforeAction: ()=>
#         Meteor.logout()
#         Session.set('_resetPasswordToken', this.params.token)
#         @subscribe('enrolledUser', this.params.token).wait()
# })


# Router.route('verify-email', {
#     path:'/verify-email/:token',
#     onBeforeAction: ->
#         console.log @
#         # Session.set('_resetPasswordToken', this.params.token)
#         # @subscribe('enrolledUser', this.params.token).wait()
#         console.log @params
#         Accounts.verifyEmail(@params.token, (err) =>
#             if err
#                 console.log err
#                 alert err
#                 @next()
#             else
#                 # alert 'email verified'
#                 # @next()
#                 Router.go "/verification_confirmation/"
#         )
# })


Router.route '*', -> @render 'requests'
    