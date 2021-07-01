Meteor.publish 'work_facets', (
    picked_staff
    picked_task
    picked_location
    # product_query
    # view_vegan
    # view_gf
    # doc_limit
    # doc_sort_key
    # doc_sort_direction
    )->
    # console.log 'dummy', dummy
    # console.log 'query', query
    console.log 'picked staff', picked_staff

    self = @
    match = {app:'pes'}
    match.model = 'work'
    # if view_vegan
    #     match.vegan = true
    # if view_gf
    #     match.gluten_free = true
    # if view_local
    #     match.local = true
    if picked_staff.length > 0 then match._author_username = picked_staff
    if picked_task.length > 0 then match.task_title = picked_task 
    # match.$regex:"#{product_query}", $options: 'i'}
    # if product_query and product_query.length > 1
    #     console.log 'searching product_query', product_query
    #     match.title = {$regex:"#{product_query}", $options: 'i'}
    #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    # #
    #     Terms.find {
    #         title: {$regex:"#{query}", $options: 'i'}
    #     },
    #         sort:
    #             count: -1
    #         limit: 42
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: picked_ingredients }
        #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 42 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]

    # else
    # unless query and query.length > 2
    # if picked_ingredients.length > 0 then match.tags = $all: picked_ingredients
    # # match.tags = $all: picked_ingredients
    # # console.log 'match for tags', match
    staff_cloud = Docs.aggregate [
        { $match: match }
        { $project: "_author_username": 1 }
        { $group: _id: "_author_username", count: $sum: 1 }
        { $match: _id: $nin: picked_staff }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    staff_cloud.forEach (staff, i) =>
        # console.log 'queried staff ', staff
        # console.log 'key', key
        self.added 'results', Random.id(),
            title: staff.name
            count: staff.count
            model:'staff'
            # category:key
            # index: i


    task_cloud = Docs.aggregate [
        { $match: match }
        { $project: "task_title": 1 }
        # { $unwind: "$tasks" }
        { $match: _id: $nin: picked_task }
        { $group: _id: "$task_title", count: $sum: 1 }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    task_cloud.forEach (task, i) =>
        # console.log 'task result ', task
        self.added 'results', Random.id(),
            title: task.title
            count: task.count
            model:'task'
            # category:key
            # index: i


    self.ready()
