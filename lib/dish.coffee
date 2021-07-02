# if Meteor.isClient
#     Router.route '/dishes', (->
#         @layout 'layout'
#         @render 'dishes'
#         ), name:'dishes'
#     Router.route '/user/:username/dishes', (->
#         @layout 'user_layout'
#         @render 'user_dishes'
#         ), name:'user_dishes'
#     Router.route '/dish/:doc_id', (->
#         @layout 'layout'
#         @render 'dish_view'
#         ), name:'dish_view'
    
#     Template.dishes.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'dish', ->
            
            
#     Template.dish_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
#     Template.dish_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    

#     Template.dish_view.helpers
#         is_cook: -> Meteor.userId() in @cook_ids
#         is_fav: -> Meteor.userId() in @favorite_user_ids
#     Template.dish_view.events
#         'click .mark_cook': ->
#             Docs.update Router.current().params.doc_id, 
#                 $addToSet: cook_ids:Meteor.userId()
#             $('body').toast(
#                 showIcon: 'food'
#                 message: "marked cooked"
#                 showProgress: 'bottom'
#                 class: 'success'
#                 # displayTime: 'auto',
#                 position: "bottom right"
#             )
#         'click .unmark_cook': ->
#             Docs.update Router.current().params.doc_id, 
#                 $pull: cook_ids:Meteor.userId()
       
#         'click .mark_fav': ->
#             Docs.update Router.current().params.doc_id, 
#                 $addToSet: favorite_user_ids:Meteor.userId()
#             $('body').toast(
#                 showIcon: 'heart'
#                 message: "marked favorite"
#                 showProgress: 'bottom'
#                 class: 'error'
#                 # displayTime: 'auto',
#                 position: "bottom right"
#             )
#         'click .unmark_fav': ->
#             Docs.update Router.current().params.doc_id, 
#                 $pull: favorite_user_ids:Meteor.userId()

#     Template.dishes.events
#         'click .add_dish': ->
#             new_id = Docs.insert 
#                 model:'dish'
#             Router.go "/dish/#{new_id}/edit"    
    
        
            
# if Meteor.isClient
#     Router.route '/dish/:doc_id/edit', (->
#         @layout 'layout'
#         @render 'dish_edit'
#         ), name:'dish_edit'



#     Template.dish_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


#     Template.dish_edit.events
#         'click .send_dish': ->
#             Swal.fire({
#                 title: 'confirm send card'
#                 text: "#{@amount} credits"
#                 icon: 'question'
#                 showCancelButton: true,
#                 confirmButtonText: 'confirm'
#                 cancelButtonText: 'cancel'
#             }).then((result) =>
#                 if result.value
#                     dish = Docs.findOne Router.current().params.doc_id
#                     Meteor.users.update Meteor.userId(),
#                         $inc:credit:-@amount
#                     Docs.update dish._id,
#                         $set:
#                             sent:true
#                             sent_timestamp:Date.now()
#                     Swal.fire(
#                         'dish sent',
#                         ''
#                         'success'
#                     Router.go "/dish/#{@_id}/"
#                     )
#             )

#         'click .delete_dish':->
#             if confirm 'delete?'
#                 Docs.remove @_id
#                 Router.go "/dishes"
            
#     Template.dish_edit.helpers
#         all_shop: ->
#             Docs.find
#                 model:'dish'
