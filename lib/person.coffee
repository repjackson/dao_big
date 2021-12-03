if Meteor.isClient
    @picked_person_tags = new ReactiveArray []
    
    Router.route '/person/:doc_id', (->
        @layout 'layout'
        @render 'person_view'
        ), name:'person_view'
    Router.route '/persons', (->
        @layout 'layout'
        @render 'persons'
        ), name:'persons'
    
            
    Template.persons.onCreated ->
        @autorun => @subscribe 'person_docs',
            picked_person_tags.array()
            Session.get('person_title_filter')
        @autorun => @subscribe 'person_facets',
            picked_person_tags.array()
            Session.get('person_title_filter')
    
    
if Meteor.isServer
    Meteor.publish 'person_model_docs', (person_id,model)->
        Docs.find 
            model:model
            person_id:person_id
        
    
    Meteor.publish 'person_docs', (person_id,model)->
        Docs.find 
            model:'person'
        
if Meteor.isClient
    Template.person_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'person_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'parent_person_from_child_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'child_persons_from_parent_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'person_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'person_products', Router.current().params.doc_id, ->
    

    Template.person_view.helpers
        person_members: ->
            Meteor.users.find 
                membership_person_ids:$in:[Router.current().params.doc_id]
        
        person_products: ->
            Docs.find 
                model:'product'
                person_id:Router.current().params.doc_id
        
        is_member: ->
            Meteor.user().membership_person_ids and Router.current().params.doc_id in Meteor.user().membership_person_ids
        
        can_join: ->
            current_person = Docs.findOne Router.current().params.doc_id
            unless current_person.private
                unless Router.current().params.doc_id in Meteor.user().membership_person_ids
                    true
                else
                    false
            else
                true
        can_leave: ->
            current_person = Docs.findOne Router.current().params.doc_id
            unless current_person.private
                unless Router.current().params.doc_id in Meteor.user().membership_person_ids
                    true
                else
                    false
                # unless Meteor.userId() in current_person.member_ids
        
    Template.person_view.events
        'click .join': ->
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    membership_person_ids:Router.current().params.doc_id
        'click .leave': ->
            Meteor.users.update Meteor.userId(),
                $pull:
                    membership_person_ids:Router.current().params.doc_id
        
        'click .add_person_member': ->
            current_person_id = Router.current().params.doc_id
            new_username = prompt('new person member username')
            console.log new_username
            
            options = {
                username:new_username
                password:new_username
                }
            console.log new_username
            Meteor.call 'create_user', options, (err,res)=>
                if err
                    alert err
                else
                    console.log res
                    # unless username
                    #     username = "#{Session.get('first_name').toLowerCase()}_#{Session.get('last_name').toLowerCase()}"
                    # console.log username
                    Meteor.users.update res,
                        $addToSet: 
                            roles: 'employee'
                            membership_person_ids:current_person_id
                            # levels: 'customer'
                        # $set:
                        #     # first_name: Session.get('first_name')
                        #     # last_name: Session.get('last_name')
                        #     # app:'nf'
                        #     username:username
                    # Router.go "/user/#{username}"
            
            
            
    Template.persons.events
        'click .add_person': ->
            new_id = Docs.insert 
                model:'person'
            Router.go "/person/#{new_id}/edit"    
        'click .pick_person_tag': -> picked_person_tags.push @title
        'click .unpick_person_tag': -> picked_person_tags.remove @valueOf()

                
            
    Template.persons.helpers
        picked_person_tags: -> picked_person_tags.array()
        current_person_title_filter: ->
            Session.get('person_title_filter')
        person_docs: ->
            match = {model:'person'}
            if Session.get('person_title_filter')
                match.title = {$regex:Session.get('person_title_filter'), $options:'i'}
            Docs.find match
            
            
        person_tag_results: ->
            Results.find {
                model:'person_tag'
            }, sort:_timestamp:-1
  
                
        
if Meteor.isServer
    Meteor.publish 'person_members', (person_id)->
        Meteor.users.find   
            membership_person_ids:$in:[person_id]
            


if Meteor.isClient
    Router.route '/person/:doc_id/edit', (->
        @layout 'layout'
        @render 'person_edit'
        ), name:'person_edit'



    Template.person_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_person_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'person'


    Template.person_edit.helpers
        nonparent_persons: ->
            current_person = 
                Docs.findOne Router.current().params.doc_id
            if current_person and current_person.parent_person_id
                Docs.find
                    model:'person'
                    # _author_id:Meteor.userId()
                    # _id:$nin:[current_person.parent_person_id]
            else 
                Docs.find
                    model:'person'
                    # _id:$ne:current_person._id
  
  
    Template.person_edit.events
        'click .delete_person':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/persons"
            
        'click .set_parent': ->
            Docs.update Router.current().params.doc_id, 
                $set: 
                    parent_person_id:@_id
                    
        'click .clear_parent_person': (e,t)->
            $(e.currentTarget).closest('.segment').transition('fly right', 500)
            Meteor.setTimeout =>
                Docs.update Router.current().params.doc_id, 
                    $unset: 
                        parent_person_id:1
                $('body').toast(
                    showIcon: 'remove'
                    message: "#{@title} removed as parent"
                    # showProgress: 'bottom'
                    class: 'error'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
            , 600
            
                    
            
            
if Meteor.isServer
    Meteor.publish 'parent_person_from_child_id', (child_id)->
        person = Docs.findOne child_id
        if person.parent_person_id
            Docs.find 
                model:'person'
                _id:person.parent_person_id
                
    Meteor.publish 'person_products', (person_id)->
        # person = Docs.findOne child_id
        Docs.find
            model:'product'
            person_id:person_id
            
            
    Meteor.publish 'child_persons_from_parent_id', (parent_id)->
        person = Docs.findOne parent_id
        Docs.find 
            model:'person'
            parent_person_id:parent_id
            
            