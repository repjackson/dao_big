# if Meteor.isClient
#     Router.route '/porters', (->
#         @layout 'layout'
#         @render 'porters'
#         ), name:'porters'
    
#     Template.porters.onCreated ->
#         # @autorun => Meteor.subscribe 'porter_tasks', ->
#         @autorun => @subscribe 'porter_docs',
#             picked_tags.array()
#             # picked_tasks.array()
#             # picked_locations.array()
#             # picked_timestamp_tags.array()
        
#         @autorun => @subscribe 'porter_facets',
#             picked_tags.array()
#             # picked_tasks.array()
#             # picked_locations.array()
#             # picked_timestamp_tags.array()
    
#     Template.porters.helpers
#         porter_tasks: ->
#             Docs.find 
#                 model:'task'
#                 station:'porters'
    
#     Template.porters.events
#         'click .add_porter_task':->
#             new_id = 
#                 Docs.insert
#                     model:'task'
#                     station:'porters'
#             Router.go "/task/#{new_id}/edit"
    
    
#         'click .log_work':->
#             # task = Docs.findOne Router.current().params.doc_id
#             if Meteor.user()
#                 new_object = {
#                     model:'work'
#                     station:'porters'
#                     task_id:@_id
#                     task_title:@title
#                     task_image_id:@image_id
#                     task_points: @points
#                 }
#                 if @location_ids.length is 1
#                     new_object.location_id = @location_ids[0]
#                 new_id = 
#                     Docs.insert new_object
#                 Docs.update @_id,
#                     $inc: work_count:1
#                 Router.go "/work/#{new_id}/edit"
    
    
                    
                            
            
            
            
# if Meteor.isServer
#     Meteor.publish 'porter_tasks', ->
#         Docs.find 
#             model:'task'
#             station:'porters'
            
            
            
#     Meteor.publish 'porter_facets', (
#         picked_tags
#         )->
    
#         self = @
#         match = {app:'pes'}
#         match.model = 'task'
#         match.station = 'porters'
#         if picked_tags.length > 0 then match.tags = $in:picked_tags
#         # match.$regex:"#{product_query}", $options: 'i'}
#         # if product_query and product_query.length > 1
#         tag_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: "tags": 1 }
#             { $group: _id: "$tags", count: $sum: 1 }
#             { $match: _id: $nin: picked_tags }
#             # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#             { $sort: count: -1, _id: 1 }
#             { $limit: 10 }
#             { $project: _id: 0, title: '$_id', count: 1 }
#         ], {
#             allowDiskUse: true
#         }
        
#         tag_cloud.forEach (tag, i) =>
#             # console.log 'queried tag ', tag
#             # console.log 'key', key
#             self.added 'results', Random.id(),
#                 title: tag.title
#                 count: tag.count
#                 model:'tag'
#                 # category:key
#                 # index: i
    
#         self.ready()
        
#     Meteor.publish 'porter_docs', (
#         picked_tags
#         )->
    
#         self = @
#         match = {app:'pes'}
#         match.model = 'task'
#         match.station = 'porters'
#         if picked_tags.length > 0 then match.tags = $in:picked_tags
    
#         Docs.find match            