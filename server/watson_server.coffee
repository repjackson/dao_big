NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
# VisualRecognitionV3 = require('ibm-watson/visual-recognition/v3')
# TextToSpeechV1 = require('ibm-watson/text-to-speech/v1')
ToneAnalyzerV3 = require('ibm-watson/tone-analyzer/v3')

{ IamAuthenticator } = require('ibm-watson/auth')



# textToSpeech = new TextToSpeechV1({
#   authenticator: new IamAuthenticator({
#     apikey: Meteor.settings.private.tts.apikey,
#   }),
#   url: Meteor.settings.private.tts.url,
# });

tone_analyzer = new ToneAnalyzerV3(
    version: '2017-09-21'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.tone.apikey
    })
    url: Meteor.settings.private.tone.url)




natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)


# visual_recognition = new VisualRecognitionV3({
#   version: '2018-03-19',
#   authenticator: new IamAuthenticator({
#     apikey: Meteor.settings.private.visual.apikey,
#   }),
#   url: Meteor.settings.private.visual.url,
# });

# const classify_params = {
#   url: 'https://ibm.biz/BdzLPG',
# };
Meteor.methods
    call_tone: (doc_id)->
        self = @
        doc = Docs.findOne doc_id
        # if doc.html or doc.body
        #     # stringed = JSON.stringify(doc.html, null, 2)
        # if mode is 'html'
        #     params =
        #         toneInput:doc["#{key}"]
        #         content_type:'text/html'
        # if mode is 'text'
        params =
            toneInput: { 'text': doc.analyzed_text }
            contentType: 'application/json'
        console.log doc.analyzed_text
        tone_analyzer.tone params, Meteor.bindEnvironment((err, response)->
            if err
            else
                # console.dir response
                Docs.update { _id: doc_id},
                    $set:
                        tone: response
            )
        # else return


    import_url: (url)->
        # console.log 'importing', url
        existing = 
            Docs.findOne 
                model:'url'
                url:url
        if existing
            return existing._id
        else
            new_id = 
                Docs.insert 
                    model:'url'
                    url:url
            returned_id = Meteor.call 'call_watson', new_id,'url','url'
            # console.log 'returned url id', returned_id
            return returned_id

    call_watson: (doc_id, key, mode) ->
        self = @
        # console.log 'doc_id', doc_id
        # console.log 'key', key
        # console.log 'mode', mode
        doc = Docs.findOne doc_id
        # if doc.skip_watson is false
        # else
        # unless doc.watson
        params =
            concepts:
                limit:20
            features:
                entities:
                    emotion: true
                    sentiment: true
                    mentions: true
                    limit: 20
                keywords:
                    emotion: true
                    sentiment: true
                    limit: 20
                concepts: {}
                emotion: {}
                categories:
                    explanation:false
                metadata: {}
                relations: {}
                # semantic_roles: {}
                sentiment: {}
        # console.log 'doc watson', doc.domain
        searchPattern = new RegExp('^' + 'self');
        if searchPattern.test(doc.domain)
            # console.log "SELF"
            params.text = doc.selftext
            params.returnAnalyzedText = true
        else if doc.domain and doc.domain in ['i.redd.it','i.imgur.com','imgur.com','gyfycat.com','reddit.com','m.youtube.com','v.redd.it','giphy.com','youtube.com','youtu.be']
            params.url = "https://www.reddit.com#{doc.permalink}"
            params.returnAnalyzedText = true
            params.clean = true
            params.features.metadata = {}
        # else if doc.domain is 'reddit.com'
        #     console.log doc.domain
        else 
            switch mode
                when 'html'
                    params.html = doc["#{key}"]
                    params.returnAnalyzedText = true
                    # params.html = doc.data.description
                    params.features.metadata = {}
                when 'text'
                    params.text = doc["#{key}"]
                    params.returnAnalyzedText = true
                    params.clean = true
                when 'comment'
                    params.text = doc.data.body
                    params.returnAnalyzedText = true
                    params.clean = true
                    # params.features.metadata = {}
                when 'link'
                    # params.url = doc["#{key}"]
                    # params.url = durl
                    params.url = doc.url
                    params.features.metadata = {}
                    params.returnAnalyzedText = true
                    params.clean = true
                when 'url'
                    # console.log 'params url'
                    # params.url = doc["#{key}"]
                    # params.url = durl
                    params.url = doc.data.url
                    params.features.metadata = {}
                    params.returnAnalyzedText = true
                    params.clean = true
                when 'video'
                    params.url = "https://www.reddit.com#{doc.permalink}"
                    params.features.metadata = {}
                    params.returnAnalyzedText = false
                    # params.clean = true
                    params.features.metadata = {}
                when 'image'
                    params.url = "https://www.reddit.com#{doc.permalink}"
                    params.returnAnalyzedText = false
                    params.clean = true
                    params.features.metadata = {}


        natural_language_understanding.analyze params, Meteor.bindEnvironment((err, response)=>
            if err
                # if err.code is 400
                    # unless err.code is 403
                    #     Docs.update doc_id,
                    #         $set:skip_watson:false
                throw new Meteor.Error(err.statusText,err.body)
                # return err
            else
                
                response = response.result
                # if Meteor.isDevelopment
                # emotions = response.emotion.document.emotion

                adding_tags = []
                # if response.categories
                #     for categories in response.categories
                #         for category in categories.label.split('/')
                #             if category.length > 0
                #                 # adding_tags.push category
                #                 Docs.update doc_id,
                #                     $addToSet:
                #                         categories: category
                #                         tags: category
                # Docs.update { _id: doc_id },
                #     $addToSet:
                #         tags:$each:adding_tags
                emotions = response.emotion.document.emotion

                emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
                # main_emotions = []
                max_emotion_percent = 0
                max_emotion_name = ''

                for emotion in emotion_list
                    if emotions["#{emotion}"] > max_emotion_percent
                        if emotions["#{emotion}"] > .5
                            max_emotion_percent = emotions["#{emotion}"]
                            max_emotion_name = emotion
                            # main_emotions.push emotion
                sadness_percent = emotions.sadness
                joy_percent = emotions.joy
                fear_percent = emotions.fear
                anger_percent = emotions.anger
                disgust_percent = emotions.disgust
                            
                Docs.update { _id: doc_id },
                    $set:
                        max_emotion_name:max_emotion_name
                        max_emotion_percent:max_emotion_percent
                        sadness_percent: sadness_percent
                        joy_percent: joy_percent
                        fear_percent: fear_percent
                        anger_percent: anger_percent
                        disgust_percent: disgust_percent
                
                if response.entities and response.entities.length > 0
                    for entity in response.entities
                        unless entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            # else
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()
                concept_array = _.pluck(response.concepts, 'text')
                lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                keyword_array = _.pluck(response.keywords, 'text')
                lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()

                keywords_concepts = lowered_keywords.concat lowered_keywords
                # Docs.update { _id: doc_id },
                #     $addToSet:
                #         tags:$each:lowered_concepts
                # console.log response
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:keywords_concepts
                    $set:
                        analyzed_text:response.analyzed_text
                        metadata:response.metadata
                        watson:true
                        sentiment:response.sentiment
                        # watson_concepts: concept_array
                        # watson_keywords: keyword_array
                        doc_sentiment_score: response.sentiment.document.score
                        doc_sentiment_label: response.sentiment.document.label

                        
                final_doc = Docs.findOne doc_id
                if mode is 'comment'
                    # console.log 'comment call'
                    # console.log final_doc
                    if final_doc.parent_doc_id
                        # console.log 'has parent doc id', final_doc.parent_doc_id
                        Docs.update final_doc.parent_doc_id,
                            $addToSet:
                                tags:$each:final_doc.tags
                # if mode is 'url'
                #     Meteor.call 'call_tone', doc_id, 'body', 'text', ->

                Meteor.call 'clear_blocklist_doc', doc_id, ->
                # if Meteor.isDevelopment
        )
        return doc_id