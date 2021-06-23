if Meteor.isClient
    Router.route '/station/:doc_id', (->
        @layout 'layout'
        @render 'station_view'
        ), name:'station_view'
    Router.route '/stations', (->
        @layout 'layout'
        @render 'stations'
        ), name:'stations'
    
            
    Template.stations.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'station', ->
    
    Template.station_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'station_work', Router.current().params.doc_id, ->
    Template.station_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'station_work', Router.current().params.doc_id, ->
    


    Template.stations.events
        'click .add_station': ->
            new_id = Docs.insert 
                model:'station'
            Router.go "/station/#{new_id}/edit"    
    
                
            
    Template.stations.helpers
        station_docs: ->
            Docs.find 
                model:'station'
                
        
if Meteor.isClient
    Router.route '/station/:doc_id/edit', (->
        @layout 'layout'
        @render 'station_edit'
        ), name:'station_edit'



    Template.station_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.station_edit.events
        'click .send_station': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    station = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update station._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'station sent',
                        ''
                        'success'
                    Router.go "/station/#{@_id}/"
                    )
            )

        'click .delete_station':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/station"
            