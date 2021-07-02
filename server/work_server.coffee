Meteor.publish 'work_facets', (
    picked_author
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
    console.log 'picked staff', picked_author

    self = @
    match = {app:'pes'}
    match.model = 'work'
    # if view_vegan
    #     match.vegan = true
    # if view_gf
    #     match.gluten_free = true
    # if view_local
    #     match.local = true
    if picked_author.length > 0 then match._author_username = picked_author
    if picked_task.length > 0 then match.task_title = picked_task 
    # match.$regex:"#{product_query}", $options: 'i'}
    # if product_query and product_query.length > 1
    author_cloud = Docs.aggregate [
        { $match: match }
        { $project: "_author_username": 1 }
        { $group: _id: "$_author_username", count: $sum: 1 }
        { $match: _id: $nin: picked_author }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    author_cloud.forEach (author, i) =>
        console.log 'queried author ', author
        # console.log 'key', key
        self.added 'results', Random.id(),
            title: author.title
            count: author.count
            model:'author'
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
    
Meteor.publish 'work_docs', (
    picked_author
    picked_task
    picked_location
    # product_query
    # view_vegan
    # view_gf
    # doc_limit
    # doc_sort_key
    # doc_sort_direction
    )->

    self = @
    match = {app:'pes'}
    match.model = 'work'
    # if view_vegan
    #     match.vegan = true
    # if view_gf
    #     match.gluten_free = true
    # if view_local
    #     match.local = true
    if picked_author.length > 0 then match._author_username = picked_author
    if picked_task.length > 0 then match.task_title = picked_task 

    Docs.find match