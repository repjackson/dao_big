Template.items.helpers
    unarchived_items: ->
        Docs.find
            model:'item'
            archived:$ne:true
    item_docs: ->
        Docs.find
            model:'item'
Template.items.events
    'click .save_item': ->
        Session.set('editing_item', null)
    'click .edit_item': ->
        Session.set('editing_item',@_id) 
    'click .add_item': ->
        new_id = 
            Docs.insert 
                model:'item'
        Session.set('editing_item', @_id)
