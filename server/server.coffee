Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # if userId and doc._id == userId
        #     true

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.private.cloudinary_key
    api_secret: Meteor.settings.private.cloudinary_secret

Docs.allow
    insert: (userId, doc) -> doc._author_id is userId
    update: (userId, doc) ->
        if userId then true
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles

Meteor.publish 'docs', (selected_tags, filter)->
    # user = Meteor.users.findOne @userId
    # console.log selected_tags
    # console.log filter
    self = @
    match = {}
    if Meteor.user()
        unless Meteor.user().roles and 'dev' in Meteor.user().roles
            match.view_roles = $in:Meteor.user().roles
    else
        match.view_roles = $in:['public']

    # if filter is 'shop'
    #     match.active = true
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if filter then match.model = filter

    Docs.find match, sort:_timestamp:-1


Meteor.methods
    log_view: (doc_id)->
        Docs.update doc_id,
            $inc:views:1


Meteor.publish 'model_from_child_id', (child_id)->
    child = Docs.findOne child_id
    Docs.find
        model:'model'
        slug:child.type


Meteor.publish 'model_fields_from_child_id', (child_id)->
    child = Docs.findOne child_id
    model = Docs.findOne
        model:'model'
        slug:child.type
    Docs.find
        model:'field'
        parent_id:model._id

Meteor.publish 'model_docs', (model,limit)->
    if limit
        Docs.find {
            model: model
            group_id: Meteor.user().current_group_id
            # app:'pes'
        }, limit:limit
    else
        Docs.find
            # app:'pes'
            group_id: Meteor.user().current_group_id
            model: model

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug
        
        

Meteor.publish 'child_docs', (id)->
    Docs.find
        parent_id:id


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug



Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    Meteor.users.find user_id

Meteor.publish 'page', (slug)->
    Docs.find
        model:'page'
        slug:slug


Meteor.publish 'doc_tags', (selected_tags)->
    user = Meteor.users.findOne @userId
    # current_herd = user.profile.current_herd

    self = @
    match = {}

    # selected_tags.push current_herd
    match.tags = $all: selected_tags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 25 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    cloud.forEach (tag, i) ->

        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

# Meteor.publish 'work_facets', ()->
#     user = Meteor.users.findOne @userId
#     # current_herd = user.profile.current_herd

#     self = @
#     match = {}

#     # selected_tags.push current_herd
#     match.tags = $all: selected_tags

#     cloud = Docs.aggregate [
#         { $match: match }
#         { $project: tags: 1 }
#         { $unwind: "$tags" }
#         { $group: _id: '$tags', count: $sum: 1 }
#         { $match: _id: $nin: selected_tags }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 25 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     cloud.forEach (tag, i) ->
#         self.added 'tags', Random.id(),
#             name: tag.name
#             count: tag.count
#             index: i

#     self.ready()


Meteor.methods
    # calc_request_stats: ->
    #     res = Docs.aggregate [
    #         { $group:
    #             _id: "$item",
    #             avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
    #             avgQuantity: { $avg: "$quantity" }
    #          }
    #     ]
    #     console.log res

    calc_user_points: (username)->
        user = Meteor.users.findOne username:username
        match = {}
        match._author_username = username
       
       
        match.model = 'work'
        match.task_points = $exists:true
        point_credit_total = 0
        
        
        point_credit_docs = Docs.find(match).fetch()
        for point_doc in point_credit_docs 
            point_credit_total += point_doc.task_points
            
        console.log 'work credit total', point_credit_total
        
        topup_match = {}
        topup_match.model = 'topup'
        topup_match.topup_amount = $exists:true
        point_topup_total = 0
        
        point_topup_docs = Docs.find(topup_match).fetch()
        for topup_doc in point_topup_docs 
            console.log topup_doc.topup_amount
            if topup_doc.topup_amount
                point_topup_total += parseInt(topup_doc.topup_amount)
            
        console.log 'topup credit total', point_topup_total
                        # 
        total_bought_credit_rank = Meteor.users.find(total_bought_credits:$gt:parseInt(point_topup_total)).count()
        console.log 'total earned credit rank', total_earned_credit_rank
        Meteor.users.update user._id, 
            $set:total_bought_credit_rank:total_bought_credit_rank+1

        # res = Docs.aggregate [
        #     { $match: match }
        #     # { $project: tags: 1 }
        #     { $group:
        #         _id: "$item",
        #         point_total: { $sum: "$task_points" },
        #         # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        #         # avgQuantity: { $avg: "$quantity" }
        #     }
        #     { $project: _id: 0, point_total: 1 }
        # ]
        # console.log res.toArray()
        # user = Meteor.users.findOne current_order._author_id
        console.log 'user points', user.points
        orders = 
            Docs.find 
                model:'order'
                _author_id:user._id
                
        total_debits = 0
        total_calories_consumed = 0
        for order in orders.fetch() 
            # console.log 'order purchase amount', order.purchase_amount
            if order.purchase_amount
                total_debits += parseInt(order.purchase_amount)
            product = Docs.findOne _id:order.product_id
            if product
                if product.calories
                    console.log 'calories added', product.calories
                    total_calories_consumed += parseInt(product.calories)
        console.log 'total debits', total_debits
        console.log 'total credits', point_credit_total
        final_calculated_current_points = point_credit_total - total_debits + point_topup_total
        
        
        console.log 'total current points', final_calculated_current_points
        if final_calculated_current_points
            Meteor.users.update user._id,
                $set:
                    points: final_calculated_current_points
            current_point_rank = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
            console.log 'amount more ranked', current_point_rank
            Meteor.users.update user._id, 
                $set:point_rank:current_point_rank+1

        calculated_total_earned_credits = point_credit_total
        calculated_total_bought_credits = point_topup_total

                # 
        total_earned_credit_rank = Meteor.users.find(total_earned_credits:$gt:parseInt(calculated_total_earned_credits)).count()
        console.log 'total earned credit rank', total_earned_credit_rank
        Meteor.users.update user._id, 
            $set:total_earned_credit_rank:total_earned_credit_rank+1

        
        calculated_total_credits = point_credit_total + point_topup_total
        
        console.log 'total current points', final_calculated_current_points
        if final_calculated_current_points
            Meteor.users.update user._id,
                $set:
                    points: final_calculated_current_points
                    total_earned_credits: point_credit_total
                    total_bought_credits: point_topup_total
                    total_credits: point_credit_total + point_topup_total
                    total_calories_consumed: total_calories_consumed
            amount = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
            console.log 'amount more ranked', amount
            Meteor.users.update user._id, 
                $set:point_rank:amount


        # res.forEach (tag, i) =>
        #     console.log tag
        #     Meteor.users.update user._id, 
        #         $set:points: tag.point_total
        #     # self.added 'tags', Random.id(),
        #     #     name: tag.name
        #     #     count: tag.count
        #     #     index: i


Meteor.publish 'me', ->
    Meteor.users.find @userId
