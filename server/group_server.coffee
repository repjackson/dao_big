Meteor.publish 'group_facets', (
    picked_tags
    )->
    self = @
    match = {app:'pes'}
    match.model = 'group'
    if picked_tags.length > 0 then match.tags = $in:picked_tags
    # if product_query and product_query.length > 1
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    tag_cloud.forEach (tag, i) =>
        # console.log 'queried tag ', tag
        # console.log 'key', key
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'tag'
            # category:key
            # index: i
    self.ready()
    
Meteor.publish 'group_docs', (
    picked_tags
    )->

    self = @
    match = {app:'pes'}
    match.model = 'group'
    if picked_tags.length > 0 then match.tags = $in:picked_tags

    Docs.find match, 
        limit:20
        sort:
            _timestamp:-1