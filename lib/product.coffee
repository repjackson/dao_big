if Meteor.isClient
    Router.route '/product/:doc_id', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'
        


    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'product_source', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'product_from_product_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'subs_from_product_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'orders_from_product_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'ingredient', ->

    Template.product_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
        Meteor.call 'calc_product_stats', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'ingredients_from_product_id', Router.current().params.doc_id
    Template.product_view.events
        'click .goto_source': (e,t)->
            $(e.currentTarget).closest('.pushable').transition('fade right', 240)
            product = Docs.findOne Router.current().params.doc_id
            Meteor.setTimeout =>
                Router.go "/source/#{product.source_id}"
            , 240
        
        # 'click .add_to_cart': ->
        #     Meteor.call 'add_to_cart', @_id, =>
        #         $('body').toast(
        #             showIcon: 'cart plus'
        #             message: "#{@title} added"
        #             # showProgress: 'bottom'
        #             class: 'success'
        #             # displayTime: 'auto',
        #             position: "bottom right"
        #         )

        'click .record_order': ->
            console.log @
            if @price_points
                new_id = 
                    Docs.insert 
                        model:'order'
                        product_id:Router.current().params.doc_id
                        purchase_amount:@price_points
                Router.go "/order/#{new_id}/edit"
            else 
                alert 'no price points'
                Router.go "/product/#{@_id}/edit"

            
    Template.product_view.helpers
        product_orders: ->
            Docs.find 
                model:'order'
                product_id:Router.current().params.doc_id
    
        editing_this: ->
            Session.equals('editing_inventory_id', @_id)
        # reservations: ->
        #     Docs.find 
        #         model:'reservation'
        #         product_id:@_id
            
        product_order_total: ->
            orders = 
                Docs.find({
                    model:'order'
                    product_id:@_id
                }).fetch()
            res = 0
            for order in orders
                res += order.order_price
            res
                

        can_cancel: ->
            product = Docs.findOne Router.current().params.doc_id
            if Meteor.userId() is product._author_id
                if product.ready
                    false
                else
                    true
            else if Meteor.userId() is @_author_id
                if product.ready
                    false
                else
                    true


        can_order: ->
            if Meteor.user().roles and 'admin' in Meteor.user().roles
                true
            else
                @cook_user_id isnt Meteor.userId()

        product_order_class: ->
            if @status is 'ready'
                'green'
            else if @status is 'pending'
                'yellow'
                
                
    Template.order_button.onCreated ->

    Template.order_button.helpers

    Template.order_button.events
        # 'click .join_waitlist': ->
        #     Swal.fire({
        #         title: 'confirm wait list join',
        #         text: 'this will charge your account if orders cancel'
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             Docs.insert
        #                 model:'order'
        #                 waitlist:true
        #                 product_id: Router.current().params.doc_id
        #             Swal.fire(
        #                 'wait list joined',
        #                 "you'll be alerted if accepted"
        #                 'success'
        #             )
        #     )

        'click .order_product': ->
            # if Meteor.user().credit >= @price_per_serving
            # Docs.insert
            #     model:'order'
            #     status:'pending'
            #     complete:false
            #     product_id: Router.current().params.doc_id
            #     if @serving_unit
            #         serving_text = @serving_unit
            #     else
            #         serving_text = 'serving'
            # Swal.fire({
            #     # title: "confirm buy #{serving_text}"
            #     title: "confirm order?"
            #     text: "this will charge you #{@price_usd}"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result) =>
            #     if result.value
            Meteor.call 'order_product', @_id, (err, res)->
                if err
                    Swal.fire(
                        'err'
                        'error'
                    )
                    console.log err
                else
                    Router.go "/order/#{res}/edit"
                    # Swal.fire(
                    #     'order and payment processed'
                    #     ''
                    #     'success'
                    # )
        # )

if Meteor.isServer
    Meteor.publish 'product_source', (product_id)->
        product = Docs.findOne product_id
        # console.log 'need source from this product', product
        Docs.find
            model:'source'
            _id:product.source_id
    Meteor.publish 'orders_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'order'
            product_id:product_id
    # Meteor.publish 'reservations_from_product_id', (product_id)->
    #     # product = Docs.findOne product_id
    #     Docs.find
    #         model:'reservations'
    #         product_id:product_id
            
    Meteor.methods
        calc_product_stats: (product_id)->
            order_count = 
                Docs.find(
                    model:'order'
                    product_id:product_id
                ).count()
            console.log order_count
            Docs.update product_id, 
                $set:
                    order_count:order_count
            



if Meteor.isClient
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'



    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'

    Template.product_edit.onRendered ->
        Meteor.setTimeout ->
            today = new Date()
            $('#availability')
                .calendar({
                    inline:true
                    # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
                    # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
                })
        , 2000

    Template.product_edit.helpers
        included_ingredients: ->
            current_product = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'ingredient'
                _id: $in:current_product.ingredient_ids
            
        unincluded_ingredients: ->
            current_product = Docs.findOne Router.current().params.doc_id
            if current_product.ingredient_ids
                Docs.find
                    model:'ingredient'
                    _id: $nin:current_product.ingredient_ids
            else
                Docs.find
                    model:'ingredient'
            
            
        can_delete: ->
            product = Docs.findOne Router.current().params.doc_id
            if product.reservation_ids
                if product.reservation_ids.length > 1
                    false
                else
                    true
            else
                true

    Template.product_edit.onCreated ->
        # @autorun => @subscribe 'source_search_results', Session.get('source_search'), ->

    Template.product_edit.events
        # 'click .remove_source': (e,t)->
        #     if confirm 'remove source?'
        #         Docs.update Router.current().params.doc_id,
        #             $set:source_id:null
        # 'click .pick_source': (e,t)->
        #     Docs.update Router.current().params.doc_id,
        #         $set:source_id:@_id
        'keyup .source_search': (e,t)->
            # if e.which is '13'
            val = t.$('.source_search').val()
            console.log val
            Session.set('source_search', val)
                
            
        'click .save_product': ->
            product_id = Router.current().params.doc_id
            # Meteor.call 'calc_product_data', product_id, ->
            Router.go "/product/#{product_id}"


        'click .add_ingredient': (e,t)->
            ingredient = Docs.findOne Router.current().params.doc_id
            # if ingredient.ingredient_ids and @_id in ingredient.ingredient_ids
            #     Docs.update Router.current().params.doc_id, 
            #         $pull:ingredient_ids:@_id
            # else
            $(e.currentTarget).closest('.item').transition('fly down', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $addToSet:ingredient_ids:@_id
            , 500
        'click .pull_ingredient': (e,t)->
            $(e.currentTarget).closest('.item').transition('fly up', 500)
            ingredient = Docs.findOne Router.current().params.doc_id
            # if ingredient.ingredient_ids and @_id in ingredient.ingredient_ids
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $pull:ingredient_ids:@_id
            , 500
            # else
            #     Docs.update Router.current().params.doc_id, 
            #         $addToSet:ingredient_ids:@_id




        # 'click .select_product': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             product_id: @_id
        #
        #
        # 'click .clear_product': ->
        #     if confirm 'clear product?'
        #         Docs.update Router.current().params.doc_id,
        #             $set:
        #                 product_id: null



        'click .delete_product': ->
            if confirm 'refund orders and cancel product?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"

if Meteor.isServer 
    Meteor.publish 'source_search_results', (source_title_query)->
        Docs.find 
            model:'source'
            title: {$regex:"#{source_title_query}",$options:'i'}