if Meteor.isClient
    Router.route '/reddit', (->
        @layout 'layout'
        @render 'reddit'
        ), name:'reddit'

    Template.registerHelper 'youtube_id', () ->
        regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
        match = @url.match(regExp)
        if (match && match[2].length == 11)
            # console.log 'match 2', match[2]
            match[2]
        else
            console.log 'error'
    
    
    Template.registerHelper 'is_image', () ->
        regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
        match = @url.match(regExp)
        # console.log 'image match', match
        if match then true
        # true
    Template.registerHelper 'is_gifv', () ->
        regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:gifv).*/
        match = @url.match(regExp)
        # console.log 'gifv match', match
        if match then true
        # true
    Template.registerHelper 'gif_filename', () ->
        @url.slice(0,-1)
        # true
    
    # Template.registerHelper 'current_doc', () ->
    #     Docs.findOne Router.current().params.doc_id
    
    Template.registerHelper 'is_image_domain', () ->
        # console.log 'image match', match
        if @domain
            console.log 'hi domain', @domain
            if @domain in ['i.imgur.com']
                console.log 'hi domain TRUE', @domain
                true
        # true
    
    Template.registerHelper 'is_video', () ->
        if @domain
            if @domain in ['v.redd.it']
                true
        # true
    
    
    Template.registerHelper 'above_50', (input) ->
        # console.log 'input', input
        # console.log @
        # console.log @["#{input}"]
        @["#{input}"] > .49
    
    Template.registerHelper 'has_thumbnail', (input) ->
        # console.log @thumbnail
        @thumbnail and @thumbnail not in ['self','default']
    
    Template.registerHelper 'parse', (input) ->
        console.log 'input', input
    
        # parser = new DOMParser()
        # doc = parser.parseFromString(input, 'text/html')
        # console.log 'dom parser', doc, doc.body
        # console.log 'dom parser', doc.body
    
        # // Otherwise, fallback to old-school method
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = input
        console.log 'innner html', dom
        return dom.value
    
    
    Template.registerHelper 'is_twitter', () ->
        @domain is 'twitter.com'
    Template.registerHelper 'is_streamable', () ->
        @domain is 'streamable.com'
    Template.registerHelper 'is_youtube', () ->
        @domain in ['youtube.com', 'youtu.be']
    
    
    Template.reddit.onCreated ->
        Session.setDefault('current_query', null)
        @autorun => @subscribe 'tag_results',
            picked_tags.array()
        @autorun => @subscribe 'doc_results',
            picked_tags.array()
    
    
    
    Template.agg_tag.events
        'click .result': (e,t)->
            # Meteor.call 'log_term', @title, ->
            picked_tags.push @title
            $('#search').val('')
            Session.set('current_query', null)
            Session.set('searching', false)
    
            Meteor.call 'search_reddit', picked_tags.array(), ->
    
    Template.reddit.events
        'click .select_query': ->
            picked_tags.push @title
            Meteor.call 'search_reddit', picked_tags.array(), ->
            $('#search').val('')
            Session.set('current_query', null)
    
    Template.reddit.events
        'click .unpick_tag': ->
            picked_tags.remove @valueOf()
            console.log picked_tags.array()
            if picked_tags.array().length > 0
                Meteor.call 'search_reddit', picked_tags.array(), =>
        # # 'keyup #search': _.throttle((e,t)->
        'keydown #search': (e,t)->
            query = $('#search').val()
            # if query.length > 0
            # console.log Session.get('current_query')
            if query.length > 0
                if e.which is 13
                    Session.set('current_query', query)
                    Session.set('searching', true)
                    search = $('#search').val().trim().toLowerCase()
                    if search.length > 0
                        picked_tags.push search
                        # console.log 'search', search
                        Meteor.call 'search_reddit', picked_tags.array(), ->
                        $('#search').val('')
                        Session.set('current_query', null)
                        Session.set('searching', false)
        # , 200)
    
        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)
    
        'click .reconnect': -> Meteor.reconnect()
    
        'click .toggle_tag': (e,t)-> picked_tags.push @valueOf()
    
        'click .print_me': (e,t)->
            console.log @
        'click .pull_post': (e,t)->
            # console.log @
            Meteor.call 'get_reddit_post', @_id, @reddit_id, =>
            # Meteor.call 'agg_omega', ->
    
    Template.shortcut.events
        'click .go': ->
            picked_tags.push @key
    Template.reddit.helpers
        not_searching: ->
            picked_tags.array().length is 0 and Session.equals('current_query',null)
            
        search_class: ->
            if Session.get('current_query')
                'big' 
            else
                if picked_tags.array().length is 0
                    'huge fluid'
                else 
                    'big' 
                    
        curent_date_setting: -> Session.get('date_setting')
    
        term_icon: ->
            console.log @
        doc_results: ->
            current_docs = Docs.find()
            # if Session.get('selected_doc_id') in current_docs.fetch()
            # console.log current_docs.fetch()
            # Docs.findOne Session.get('selected_doc_id')
            doc_count = Docs.find().count()
            # if doc_count is 1
            Docs.find({}, limit:10)
    
    
        is_loading: -> Session.get('is_loading')
    
        tag_result_class: ->
            # ec = omega.emotion_color
            # console.log @
            # console.log omega.total_doc_result_count
            total_doc_result_count = Docs.find({}).count()
            console.log total_doc_result_count
            percent = @count/total_doc_result_count
            # console.log 'percent', percent
            # console.log typeof parseFloat(@relevance)
            # console.log typeof (@relevance*100).toFixed()
            whole = parseInt(percent*10)+1
            # console.log 'whole', whole
    
            # if whole is 0 then "#{ec} f5"
            if whole is 0 then "f5"
            else if whole is 1 then "f11"
            else if whole is 2 then "f12"
            else if whole is 3 then "f13"
            else if whole is 4 then "f14"
            else if whole is 5 then "f15"
            else if whole is 6 then "f16"
            else if whole is 7 then "f17"
            else if whole is 8 then "f18"
            else if whole is 9 then "f19"
            else if whole is 10 then "f20"
    
    
        connection: ->
            # console.log Meteor.status()
            Meteor.status()
        connected: -> Meteor.status().connected
    
        unpicked_tags: ->
            # # doc_count = Docs.find().count()
            # # console.log 'doc count', doc_count
            # # if doc_count < 3
            # #     Tags.find({count: $lt: doc_count})
            # # else
            # unless Session.get('searching')
            #     unless Session.get('current_query').length > 0
            Tags.find({})
    
        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'
    
        picked_tags: -> picked_tags.array()
    
        picked_tags_plural: -> picked_tags.array().length > 1
    
        searching: ->
            # console.log 'searching?', Session.get('searching')
            Session.get('searching')
    
        one_post: -> Docs.find().count() is 1
    
        two_posts: -> Docs.find().count() is 2
        three_posts: -> Docs.find().count() is 3
        four_posts: -> Docs.find().count() is 4
        more_than_four: -> Docs.find().count() > 4
        one_result: ->
            Docs.find().count() is 1
    
        docs: ->
            # if picked_tags.array().length > 0
            cursor =
                Docs.find {
                    model:'reddit'
                },
                    sort:
                        ups:-1
                    limit:10
            # console.log cursor.fetch()
            cursor
    
    
        home_subs_ready: ->
            Template.instance().subscriptionsReady()
            
            
        # Router.route '/doc/:doc_id/view', (->
        #     @layout 'layout'
        #     @render 'doc_page'
        #     ), name:'doc_page'
    
    
        # Template.doc_page.onCreated ->
        #     # @autorun => Meteor.subscribe('doc', Router.current().params.doc_id)
        #     # Meteor.subscribe 'doc', Router.current().params.doc_id
        #     @autorun => Meteor.subscribe 'current_doc', Router.current().params.doc_id
        #     console.log @
    Template.doc_page.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000

    Template.doc_page.events
        'click .select_doc_tag': ->
            picked_tags.push @valueOf()
            # Router.go '/'
            Meteor.call 'search_reddit', picked_tags.array(), ->

        'click .call_watson': ->
            # Meteor.call 'call_watson', Router.current().params.doc_id,'body','html', ->
            Meteor.call 'call_watson', @_id,'body','html', ->
    
        'click .print_me': ->
            console.log @
    
    # Template.array_view.events
    #     'click .toggle_post_filter': ->
    #         console.log @
    #         value = @valueOf()
    #         console.log Template.currentData()
    #         current = Template.currentData()
    #         console.log Template.parentData()
            # match = Session.get('match')
            # key_array = match["#{current.key}"]
            # if key_array
            #     if value in key_array
            #         key_array = _.without(key_array, value)
            #         match["#{current.key}"] = key_array
            #         picked_tags.remove value
            #         Session.set('match', match)
            #     else
            #         key_array.push value
            #         picked_tags.push value
            #         Session.set('match', match)
            #         Meteor.call 'search_reddit', picked_tags.array(), ->
            #         # Meteor.call 'agg_idea', value, current.key, 'entity', ->
            #         console.log @
            #         # match["#{current.key}"] = ["#{value}"]
            # else
            # if value in picked_tags.array()
            #     picked_tags.remove value
            # else
            #     # match["#{current.key}"] = ["#{value}"]
            #     picked_tags.push value
            #     # console.log picked_tags.array()
            # # Session.set('match', match)
            # # console.log picked_tags.array()
            # if picked_tags.array().length > 0
            #     Meteor.call 'search_reddit', picked_tags.array(), ->
            # console.log Session.get('match')

    # Template.array_view.helpers
    #     values: ->
    #         # console.log @key
    #         Template.parentData()["#{@key}"]
    #
    #     post_label_class: ->
    #         match = Session.get('match')
    #         key = Template.parentData().key
    #         doc = Template.parentData(2)
    #         # console.log key
    #         # console.log doc
    #         # console.log @
    #         if @valueOf() in picked_tags.array()
    #             'active'
    #         else
    #             'basic'
    #         # if match["#{key}"]
    #         #     if @valueOf() in match["#{key}"]
    #         #         'active'
    #         #     else
    #         #         'basic'
    #         # else
    #         #     'basic'
    #




    Template.doc_page.onCreated ->
        @view_detail = new ReactiveVar false
        # @autorun => @subscribe 'doc', Router.current().params.doc_id

    Template.doc_page.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000

    Template.doc_page.helpers
        view_tone: -> Session.get('view_tone')

        when: -> moment(@_timestamp).fromNow()
        view_detail: -> Template.instance().view_detail.get()
    Template.doc_page.events
        'click .toggle_detail': (e,t)->
            t.view_detail.set !t.view_detail.get()
        'click .remove': ->
            Docs.remove @_id



