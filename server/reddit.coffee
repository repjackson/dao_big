request = require('request')
rp = require('request-promise');
Meteor.methods
    # search_reddit: (query)->
    #     # @unblock()
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/search.json?q=#{query}&limit=100&include_facets=true&raw_json=1"
    #     # url = "https://www.reddit.com/user/hernannadal/about.json"
    #     options = {
    #         url: url
    #         headers: 
    #             # 'accept-encoding': 'gzip'
    #             "User-Agent": "web:com.dao.af:v1.2.3 (by /u/dao-af)"
    #         # gzip: true
    #     }
    #     console.log 'searching', query
    #     rp(options)
    #         .then(Meteor.bindEnvironment((res)->
    #             parsed = JSON.parse(res)
    #             # if parsed.data.dist > 1
    #             _.each(parsed.data.children, (item)=>
    #                 # unless item.domain is "OneWordBan"
    #                 data = item.data
    #                 len = 200
    #                 added_tags = [query]
    #                 # added_tags.push data.domain.toLowerCase()
    #                 # added_tags.push data.subreddit.toLowerCase()
    #                 # added_tags.push data.title.toLowerCase()
    #                 # added_tags.push data.author.toLowerCase()
    #                 added_tags = _.flatten(added_tags)
    #                 existing = Docs.findOne 
    #                     model:'rpost'
    #                     url:data.url
    #                     subreddit:data.subreddit
    #                 # if existing
    #                 #     # if Meteor.isDevelopment
    #                 #     # if typeof(existing.tags) is 'string'
    #                 #     #     Doc.update
    #                 #     #         $unset: tags: 1
    #                 #     Docs.update existing._id,
    #                 #         $addToSet: tags: $each: added_tags
    #                 #         $set:
    #                 #             url: data.url
    #                 #             domain: data.domain
    #                 #             selftext: data.selftext
    #                 #             selftext_html: data.selftext_html
    #                 #             comment_count: data.num_comments
    #                 #             permalink: data.permalink
    #                 #             body: data.body
    #                 #             thumbnail: data.thumbnail
    #                 #             is_reddit_media_domain: data.is_reddit_media_domain
    #                 #             link_title: data.link_title
    #                 #             body_html: data.body_html
    #                 #             ups: data.ups
    #                 #             title: data.title
    #                 #             created_utc: data.created_utc
    #                 #             # html:data.media.oembed.html    
    #                 #         $unset:
    #                 #             data:1
    #                 #             # watson:1
    #                     # if data.media
    #                     #     if data.media.oembed
    #                     #         if data.media.oembed.html
    #                     #             Docs.update existing._id,
    #                     #                 $set:
    #                     #                     html: data.media.oembed.html

    #                         # $set:data:data

    #                     # Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                 unless existing
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         thumbnail: data.thumbnail
    #                         body_html: data.body_html
    #                         permalink: data.permalink
    #                         selftext: data.selftext
    #                         selftext_html: data.selftext_html
    #                         is_reddit_media_domain: data.is_reddit_media_domain
    #                         ups: data.ups
    #                         title: data.title
    #                         link_title: data.link_title
    #                         created_utc: data.created_utc
    #                         # html:data.media.oembed.html    
    #                         subreddit: data.subreddit
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'rpost'
    #                         # source:'reddit'
    #                         # data:data
    #                     if data.media
    #                         if data.media.oembed
    #                             if data.media.oembed.html
    #                                 reddit_post.html = data.media.oembed.html
    #                     new_reddit_post_id = Docs.insert reddit_post
    #                     # if Meteor.isDevelopment
    #                     # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             Meteor.call 'call_wiki', query, ->        
    #             )
    #         )).catch((err)->
    #         )

   



Meteor.methods
    call_wiki: (query)->
        # term = query.split(' ').join('_')
        # term = query[0]
        @unblock()
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&generator=searchformat=json&search=#{term}",(err,response)=>
            unless err
                for term,i in response.data[1]
                    url = response.data[3][i]
    
    
                    found_doc =
                        Docs.findOne
                            url: url
                            model:'wikipedia'
                    if found_doc
                        # Docs.update found_doc._id,
                        #     # $pull:
                        #     #     tags:'wikipedia'
                        #     $set:
                        #         title:found_doc.title.toLowerCase()
                        unless found_doc.metadata
                            Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                    else
                        new_wiki_id = Docs.insert
                            title:term.toLowerCase()
                            tags:[term.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1
                            url:url
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->

    # search_reddit: (query)->
    #     @unblock()
    #     # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/search.json?q=#{query}&limit=30&include_facets=false&raw_json=1"
    #     # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
    #     HTTP.get url,(err,res)=>
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children, (item)=>
    #                 unless item.domain is "OneWordBan"
    #                     data = item.data
    #                     len = 200
    #                     # if typeof(query) is String
    #                     #     added_tags = [query]
    #                     # else
    #                     added_tags = [query]
    #                     # added_tags = [query]
    #                     # added_tags.push data.domain.toLowerCase()
    #                     # added_tags.push data.subreddit.toLowerCase()
    #                     # added_tags.push data.author.toLowerCase()
    #                     added_tags = _.flatten(added_tags)
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         permalink: data.permalink
    #                         ups: data.ups
    #                         title: data.title
    #                         subreddit: data.subreddit
    #                         # root: query
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'reddit'
    #                         # source:'reddit'
    #                     existing = Docs.findOne 
    #                         model:'reddit'
    #                         url:data.url
    #                     if existing
    #                         # if Meteor.isDevelopment
    #                         # if typeof(existing.tags) is 'string'
    #                         #     Doc.update
    #                         #         $unset: tags: 1
    #                         Docs.update existing._id,
    #                             $addToSet: tags: $each: added_tags

    #                         Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                     unless existing
    #                         # if Meteor.isDevelopment
    #                         new_reddit_post_id = Docs.insert reddit_post
    #                         # Meteor.users.update Meteor.userId(),
    #                         #     $inc:points:1
    #                         Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             )
   
    # reddit_best: (query)->
    #     @unblock()
        
    #     # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/best.json?q=#{query}&nsfw=1&limit=30&include_facets=false&raw_json=1"
    #     # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
    #     HTTP.get url,(err,res)=>
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children, (item)=>
    #                 unless item.domain is "OneWordBan"
    #                     data = item.data
    #                     len = 200
    #                     # if typeof(query) is String
    #                     #     added_tags = [query]
    #                     # else
    #                     added_tags = [query]
    #                     # added_tags = [query]
    #                     # added_tags.push data.domain.toLowerCase()
    #                     # added_tags.push data.subreddit.toLowerCase()
    #                     # added_tags.push data.author.toLowerCase()
    #                     added_tags = _.flatten(added_tags)
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         permalink: data.permalink
    #                         ups: data.ups
    #                         title: data.title
    #                         subreddit: data.subreddit
    #                         # root: query
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'reddit'
    #                         # source:'reddit'
    #                     existing = Docs.findOne 
    #                         model:'reddit'
    #                         url:data.url
    #                     if existing
    #                         # if Meteor.isDevelopment
    #                         # if typeof(existing.tags) is 'string'
    #                         #     Doc.update
    #                         #         $unset: tags: 1
    #                         Docs.update existing._id,
    #                             $addToSet: tags: $each: added_tags
    #                         Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                     unless existing
    #                         new_reddit_post_id = Docs.insert reddit_post
    #                         # if Meteor.isDevelopment
    #                         # Meteor.users.update Meteor.userId(),
    #                         #     $inc:points:1
    #                         Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             )
    
    # reddit_new: (query)->
    #     @unblock()
        
    #     # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/new.json?q=#{query}&nsfw=1&limit=30&include_facets=false&raw_json=1"
    #     # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
    #     HTTP.get url,(err,res)=>
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children, (item)=>
    #                 unless item.domain is "OneWordBan"
    #                     data = item.data
    #                     len = 200
    #                     # if typeof(query) is String
    #                     #     added_tags = [query]
    #                     # else
    #                     added_tags = [query]
    #                     # added_tags = [query]
    #                     # added_tags.push data.domain.toLowerCase()
    #                     # added_tags.push data.subreddit.toLowerCase()
    #                     # added_tags.push data.author.toLowerCase()
    #                     added_tags = _.flatten(added_tags)
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         permalink: data.permalink
    #                         ups: data.ups
    #                         title: data.title
    #                         subreddit: data.subreddit
    #                         # root: query
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'reddit'
    #                         # source:'reddit'
    #                     existing = Docs.findOne 
    #                         model:'reddit'
    #                         url:data.url
    #                     if existing
    #                         # if Meteor.isDevelopment
    #                         # if typeof(existing.tags) is 'string'
    #                         #     Doc.update
    #                         #         $unset: tags: 1
    #                         Docs.update existing._id,
    #                             $addToSet: tags: $each: added_tags
    #                         Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                     unless existing
    #                         new_reddit_post_id = Docs.insert reddit_post
    #                         # if Meteor.isDevelopment
        
    #                         # Meteor.users.update Meteor.userId(),
    #                         #     $inc:points:1
    #                         Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             )
    
            
    # reddit_all: ->
    #     total = 
    #         Docs.find({
    #             model:'reddit'
    #             subreddit: $exists:false
    #         }, limit:100)
    #     total.forEach( (doc)->
    #     for doc in total.fetch()
    #         Meteor.call 'get_reddit_post', doc._id, doc.reddit_id, ->
    #     )


    # get_reddit_post: (doc_id, reddit_id, root)->
    #     @unblock()
    #     doc = Docs.findOne doc_id
    #     if doc.reddit_id
    #         # HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json&raw_json=1", (err,res)->
    #         HTTP.get "https://www.reddit.com/comments/#{doc.reddit_id}/.json", (err,res)->
    #             if err then console.error err
    #             else
    #                 rd = res.data.data.children[0].data
    #                 if rd.is_video
    #                     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
    #                 else if rd.is_image
    #                     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #                 else
    #                     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #                     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #                     # Meteor.call 'call_visual', doc_id, ->
    #                 if rd.selftext
    #                     unless rd.is_video
    #                         # if Meteor.isDevelopment
    #                         Docs.update doc_id, {
    #                             $set:
    #                                 body: rd.selftext
    #                         }, ->
    #                         #     Meteor.call 'pull_subreddit', doc_id, url
    #                 if rd.selftext_html
    #                     unless rd.is_video
    #                         Docs.update doc_id, {
    #                             $set:
    #                                 html: rd.selftext_html
    #                         }, ->
    #                             # Meteor.call 'pull_subreddit', doc_id, url
    #                 if rd.url
    #                     unless rd.is_video
    #                         url = rd.url
    #                         # if Meteor.isDevelopment
    #                         Docs.update doc_id, {
    #                             $set:
    #                                 reddit_url: url
    #                                 url: url
    #                         }, ->
    #                             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #                 update_ob = {}
    #                 if rd.preview
    #                     if rd.preview.images[0].source.url
    #                         thumbnail = rd.preview.images[0].source.url
    #                 else
    #                     thumbnail = rd.thumbnail
    #                 Docs.update doc_id,
    #                     $set:
    #                         data: rd
    #                         url: rd.url
    #                         # reddit_image:rd.preview.images[0].source.url
    #                         thumbnail: rd.thumbnail
    #                         subreddit: rd.subreddit
    #                         author: rd.author
    #                         domain: rd.domain
    #                         is_video: rd.is_video
    #                         ups: rd.ups
    #                         # downs: rd.downs
    #                         over_18: rd.over_18
    get_reddit_post: (doc_id, reddit_id, root)->
        @unblock()
        doc = Docs.findOne doc_id
        if doc.reddit_id
            # HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json&raw_json=1", (err,res)->
            HTTP.get "https://www.reddit.com/comments/#{doc.reddit_id}/.json", (err,res)->
                if err
                    console.error err
                unless err
                    rd = res.data[0].data.children[0].data
                    Docs.update doc_id,
                        $set:
                            data: rd
                            url: rd.url
                            # reddit_image:rd.preview.images[0].source.url
                            thumbnail: rd.thumbnail
                            subreddit: rd.subreddit
                            group:rd.subreddit
                            author: rd.author
                            domain: rd.domain
                            is_video: rd.is_video
                            ups: rd.ups
                            # downs: rd.downs
                            over_18: rd.over_18

        
Meteor.methods
    call_alpha: (query)->
        # @unblock()
        found_alpha = 
            Docs.findOne 
                model:'alpha'
                query:query
        if found_alpha
            target = found_alpha
            # if target.updated
            #     return target
        else
            target_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    tags:[query]
            target = Docs.findOne target_id       
                   
                    
        HTTP.get "http://api.wolframalpha.com/v1/spoken?i=#{query}&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            if response
                Docs.update target._id,
                    $set:
                        voice:response.content  
            # HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=3&format=html,image,plaintext,sound&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=5&format=html,image,plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
                if response
                    parsed = JSON.parse(response.content)
                    Docs.update target._id,
                        $set:
                            response:parsed  
                            updated:true


                            
    add_chat: (chat)->
        @unblock()
        # now = Date.now()
        # found_last_chat = 
        #     Docs.findOne { 
        #         model:'global_chat'
        #         _timestamp: $lt:now
        #     }, limit:1
        # new_id = 
        #     Docs.insert 
        #         model:'global_chat'
        #         body:chat
        #         bot:false
        HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{chat}",(err,res)=>
            if res
                parsed = JSON.parse(res.content)
                Docs.insert
                    model:'global_chat'
                    bot:true
                    res:parsed
                return parsed
                
                
    arespond: (post_id)->
        # @unblock()
        post = Docs.findOne post_id
        # now = Date.now()
        # found_last_chat = 
        #     Docs.findOne { 
        #         model:'global_chat'
        #         _timestamp: $lt:now
        #     }, limit:1
        # new_id = 
        #     Docs.insert 
        #         model:'global_chat'
        #         body:chat
        #         bot:false
        HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{post.body}",(err,response)=>
            if response
                parsed = JSON.parse(response.content)
                Docs.insert
                    model:'alpha_response'
                    bot:true
                    response:parsed
                    parent_id:post_id
                    
                    
Meteor.publish 'tag_results', (
    picked_tags
    query
    searching
    dummy
    )->
    # console.log 'dummy', dummy
    # console.log 'selected tags', picked_tags
    # console.log 'query', query
    # console.log 'searching?', searching

    self = @
    match = {}

    # match.model = $in: ['reddit','wikipedia']
    match.model = 'reddit'
    # console.log 'query length', query.length
    # if query


    match.tags = $all: picked_tags
    agg_doc_count = Docs.find(match).count()
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $match: count: $lt: agg_doc_count }
        # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 11 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    tag_cloud.forEach (tag, i) =>
        # console.log 'queried tag ', tag
        # console.log 'key', key
        self.added 'tags', Random.id(),
            title: tag.name
            count: tag.count
            # category:key
            # index: i
    # console.log doc_tag_cloud.count()
    self.ready()


Meteor.publish 'doc_results', (
    picked_tags
    # current_query
    # date_setting
    )->
    # console.log 'got selected tags', picked_tags
    # else
    self = @
    # console.log 'searching query', current_query
    # match = {model:$in:['reddit','wikipedia']}
    match = {model:'reddit'}
    #         yesterday = now-day
    #         # console.log yesterday
    #         match._timestamp = $gt:yesterday

    # if picked_tags.length > 0
    #     # if picked_tags.length is 1
    #     #     console.log 'looking single doc', picked_tags[0]
    #     #     found_doc = Docs.findOne(title:picked_tags[0])
    #     #
    #     #     match.title = picked_tags[0]
    #     # else
    match.tags = $all: picked_tags
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            ups:-1
            # points:-1
        limit:20
        fields:
            youtube_id:1
            thumbnail:1
            url:1
            title:1
            model:1
            tags:1
            _timestamp:1
            domain:1


Meteor.methods
    search_reddit: (query)->
        console.log 'searching reddit for', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on&limit=20&include_facets=true",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on&limit=100&include_facets=true",(err,response)=>
            # console.log response.data
            if err then console.log err
            else if response.data.data.dist > 1
                console.log 'found data'
                # console.log 'data length', response.data.data.children.length
                _.each(response.data.data.children, (item)=>
                    # console.log item.data
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # added_tags = _.flatten(added_tags)
                        # console.log 'added_tags', added_tags
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            comment_count: data.num_comments
                            permalink: data.permalink
                            title: data.title
                            # root: query
                            selftext: false
                            # thumbnail: false
                            tags: query
                            model:'reddit'
                        existing_doc = Docs.findOne url:data.url
                        if existing_doc
                            # if Meteor.isDevelopment
                                # console.log 'skipping existing url', data.url
                                # console.log 'adding', query, 'to tags'
                            # console.log 'type of tags', typeof(existing_doc.tags)
                            # if typeof(existing_doc.tags) is 'string'
                            #     # console.log 'unsetting tags because string', existing_doc.tags
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing_doc._id,
                                $addToSet: tags: $each: query

                                # console.log 'existing doc', existing_doc.title
                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                        unless existing_doc
                            # console.log 'importing url', data.url
                            new_reddit_post_id = Docs.insert reddit_post
                            # console.log 'calling watson on ', reddit_post.title
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                                # console.log 'get post res', res
                    else
                        console.log 'NO found data'
                )

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        #     console.log item.data
        # )


    # get_reddit_post: (doc_id, reddit_id, root)->
    #     # console.log 'getting reddit post', doc_id, reddit_id
    #     HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
    #         if err then console.error err
    #         else
    #             rd = res.data.data.children[0].data
    #             # console.log rd
    #             result =
    #                 Docs.update doc_id,
    #                     $set:
    #                         rd: rd
    #             # console.log result
    #             # if rd.is_video
    #             #     # console.log 'pulling video comments watson'
    #             #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
    #             # else if rd.is_image
    #             #     # console.log 'pulling image comments watson'
    #             #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #             # else
    #             #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #             #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #             #     # Meteor.call 'call_visual', doc_id, ->
    #             if rd.selftext
    #                 unless rd.is_video
    #                     # if Meteor.isDevelopment
    #                     #     console.log "self text", rd.selftext
    #                     Docs.update doc_id, {
    #                         $set:
    #                             body: rd.selftext
    #                     }, ->
    #                     #     Meteor.call 'pull_site', doc_id, url
    #                         # console.log 'hi'
    #             if rd.selftext_html
    #                 unless rd.is_video
    #                     Docs.update doc_id, {
    #                         $set:
    #                             html: rd.selftext_html
    #                     }, ->
    #                         # Meteor.call 'pull_site', doc_id, url
    #                         # console.log 'hi'
    #             if rd.url
    #                 unless rd.is_video
    #                     url = rd.url
    #                     # if Meteor.isDevelopment
    #                     #     console.log "found url", url
    #                     Docs.update doc_id, {
    #                         $set:
    #                             reddit_url: url
    #                             url: url
    #                     }, ->
    #                         # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #             # update_ob = {}

    #             Docs.update doc_id,
    #                 $set:
    #                     rd: rd
    #                     url: rd.url
    #                     thumbnail: rd.thumbnail
    #                     subreddit: rd.subreddit
    #                     author: rd.author
    #                     is_video: rd.is_video
    #                     ups: rd.ups
    #                     # downs: rd.downs
    #                     over_18: rd.over_18
    #                 # $addToSet:
    #                 #     tags: $each: [rd.subreddit.toLowerCase()]
    #             # console.log Docs.findOne(doc_id)
