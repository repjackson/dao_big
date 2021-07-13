if Meteor.isClient
    Router.route '/user/:username/points', (->
        @layout 'user_layout'
        @render 'user_points'
        ), name:'user_points'

    # Template.user_orders.onCreated ->
    #     @autorun => Meteor.subscribe 'user_orders', Router.current().params.username, ->
    Template.user_points.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_work', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_topups', Router.current().params.username, ->
        Meteor.call 'calc_user_points', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'model_docs', 'product'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # @autorun => Meteor.subscribe 'my_topups'
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
        #     locale: 'auto'
        #     # zipCode: true
        #     token: (token) ->
        #         # product = Docs.findOne Router.current().params.doc_id
        #         user = Meteor.users.findOne username:Router.current().params.username
        #         deposit_amount = parseInt $('.deposit_amount').val()*100
        #         stripe_charge = deposit_amount*100*1.02+20
        #         # calculated_amount = deposit_amount*100
        #         # console.log calculated_amount
        #         charge =
        #             amount: deposit_amount*1.02+20
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
        #             if error then alert error.reason, 'danger'
        #             else
        #                 alert 'payment received', 'success'
        #                 Docs.insert
        #                     model:'deposit'
        #                     deposit_amount:deposit_amount/100
        #                     stripe_charge:stripe_charge
        #                     amount_with_bonus:deposit_amount*1.05/100
        #                     bonus:deposit_amount*.05/100
        #                 Meteor.users.update user._id,
        #                     $inc: points: deposit_amount*1.05/100
    	# )


    # Template.user_points.events
    #     'click .add_pointss': ->
    #         amount = parseInt $('.deposit_amount').val()
    #         amount_times_100 = parseInt amount*100
    #         calculated_amount = amount_times_100*1.02+20
    #         # Template.instance().checkout.open
    #         #     name: 'points deposit'
    #         #     # email:Meteor.user().emails[0].address
    #         #     description: 'gold run'
    #         #     amount: calculated_amount
    #         Docs.insert
    #             model:'deposit'
    #             amount: amount
    #         Meteor.users.update Meteor.userId(),
    #             $inc: points: amount_times_100


    #     'click .initial_withdrawal': ->
    #         withdrawal_amount = parseInt $('.withdrawal_amount').val()
    #         if confirm "initiate withdrawal for #{withdrawal_amount}?"
    #             Docs.insert
    #                 model:'withdrawal'
    #                 amount: withdrawal_amount
    #                 status: 'started'
    #                 complete: false
    #             Meteor.users.update Meteor.userId(),
    #                 $inc: points: -withdrawal_amount

    #     'click .cancel_withdrawal': ->
    #         if confirm "cancel withdrawal for #{@amount}?"
    #             Docs.remove @_id
    #             Meteor.users.update Meteor.userId(),
    #                 $inc: points: @amount



    Template.user_work.helpers
        user_work_docs: ->
            Docs.find {
                model:'work'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1

    # Template.user_points.helpers
    #     user_orders: ->
    #         Docs.find {
    #             model:'order'
    #             _author_username: Router.current().params.username
    #         }, sort:_timestamp:-1

    Template.user_topups.helpers
        user_topup_docs: ->
            Docs.find {
                model:'topup'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1



    Template.user_points.events
        'click .top_up': ->
            amount = prompt('amount?')
            if amount
                user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert 
                    model:'topup'
                    topup_amount:parseInt(amount)
                Meteor.call 'calc_user_points', Router.current().params.username, ->
            # Meteor.users.update Meteor.userId(),
            #     $inc:points:1
            #     # $set:points:1

        'click .remove_points': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.update Meteor.userId(),
                $inc:points:-1
        'click .add_pointss': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            calculated_amount = deposit_amount*1.02+20
            # Template.instance().checkout.open
            #     name: 'points deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount



    Template.user_dashboard.onCreated ->
        # @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
    Template.user_dashboard.helpers

    Template.user_dashboard.events
            
            
if Meteor.isServer
    Meteor.publish 'user_work', (username)->
        # user = Meteor.users.findOne username:username
        Docs.find({
            model:'work'
            _author_username:username
        }, limit:20)
            
            
    Meteor.publish 'user_topups', (username)->
        # user = Meteor.users.findOne username:username
        Docs.find({
            model:'topup'
            _author_username:username
        }, limit:20)
            
            
            