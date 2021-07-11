Template.doc_emotion.onCreated ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 1000
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 1000

Template.small_sentiment.onCreated ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 1000

Template.small_sentiment.helpers
    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'

Template.call_tone.events
    'click #call_tone': ->
        console.log @
        Meteor.call 'call_tone', Router.current().params.doc_id, ->

Template.tone_view.events
    'click .upvote_sentence': ->
        console.log @
        console.log Template.currentData()
        console.log Template.parentData()
        Meteor.call 'upvote_sentence', Template.currentData()._id, @, ->
    'click .downvote_sentence': ->
        console.log @
        Meteor.call 'downvote_sentence', Template.currentData()._id, @, ->
    'keyup .tag_sentence': (e,t)->
        if e.which is 13
            tag = $(e.currentTarget).closest('.tag_sentence').val().trim()
            
            # console.log tag
            if tag
                Meteor.call 'tag_sentence', Template.currentData()._id, @, tag, ->
                $(e.currentTarget).closest('.tag_sentence').val('')



Template.doc_emotion.helpers
    # sadness_percent: -> (@sadness*100).toFixed()            
    # joy_percent: -> (@joy*100).toFixed()   
    # disgust_percent: -> (@disgust*100).toFixed()         
    # anger_percent: -> (@anger*100).toFixed()
    # fear_percent: -> (@fear*100).toFixed()


    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
            
        
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'
        
    is_positive: -> if @doc_sentiment_label is 'positive' then true else false    


Template.keywords.helpers
    relevance_percent: -> (@relevance*100).toFixed()

    sentiment_percent: -> 
        (@sentiment.score*100).toFixed()

    sadness_percent: -> (@sadness*100).toFixed()            
    # joy_percent: -> (@joy*100).toFixed()   
    disgust_percent: -> (@disgust*100).toFixed()         
    anger_percent: -> (@anger*100).toFixed()
    fear_percent: -> (@fear*100).toFixed()

Template.keywords.onRendered ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 2000
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 2000
    
    
Template.call_watson.events
    'click .autotag': -> 
        $('body').toast(
            position: 'bottom center',
            showIcon: 'brain'
            message: 'autotagging'
            # displayTime: 'auto',
        )
        # Meteor.call 'call_watson',Router.current().params.doc_id,'url','url',(err,res)=>
        Meteor.call 'call_watson',Router.current().params.doc_id,@key,@mode,(err,res)=>
            if err
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'alert'
                    message: 'error', err.error
                    # displayTime: 'auto',
                    classProgress: 'purple'
                )
            else 
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    message: 'autotagged', res
                    # displayTime: 'auto',
                    class:'success'
                    classProgress: 'blue'
                )

Template.get_emotion.events
    'click .get': -> 
        $('body').toast(
            position: 'bottom center',
            showIcon: 'refresh'
            message: 'getting emotion'
            displayTime: 'auto',
        )
        Meteor.call 'get_emotion',Router.current().params.doc_id,'body',(err,res)=>
            if err
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'question'
                    message: 'error getting emotion', err.error
                    displayTime: 'auto',
                )
            else 
                $('body').toast(
                    position: 'bottom center',
                    showIcon: 'checkmark'
                    message: 'emotion', res
                    displayTime: 'auto',
                )

# Template.call_visual_analysis.events
#     'click #call_visual': ->
#         Meteor.call 'call_visual', Router.current().params.doc_id, ->



Template.doc_sentiment.onRendered ->
    # Meteor.setTimeout ->
    #     $('.progress').progress()
    # , 2000


Template.doc_sentiment.helpers
    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
            
        
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'
        
    is_positive: -> if @doc_sentiment_label is 'positive' then true else false