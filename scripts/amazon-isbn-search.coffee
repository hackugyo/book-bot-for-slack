module.exports.searchIsbn = (client, keyword, callback) ->
    client.itemSearch {
        keywords: keyword,
        searchIndex: 'Books',
        responseGroup: 'ItemAttributes',
        domain: 'ecs.amazonaws.jp',
    }, (err, results) ->
        if err
            console.log(keyword + ' : error!')
            return callback err # ここで打ち止め


        message = if (!results? || results?.length == 0) then "#{keyword}: 見つかりませんでした。" else ''
        return callback message unless results?

        for result,i in results
            if (i >= 1)
                message += "ほか #{results.length - 1}件"
                message += "以上" if results.length >= 10
                break
            title = result.ItemAttributes[0].Title
            isbn13 = result.ItemAttributes[0].EAN?[0] # EANの存在確認
            isbn13 = ('ASIN ' +  result.ASIN?[0]) unless isbn13?
            url = "http://www.amazon.co.jp/dp/#{result.ASIN?[0]}" # result.DetailPageURL[0]
            # url += "%3FSubscriptionId%3DAKIAIFD3V43BPAIS2WFA%26tag%3Dpubkugyo-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D#{ASIN}"
            message += isbn13 + ' ' + title + ' ' + url + '\n'
        callback null, message

module.exports.searchIsbns = (client, keywords, callback) ->
    # sleep関数
    sleep = (ms, func) ->
        setTimeout func, ms

    async = require 'async'
    results = []
    async.eachSeries keywords, (keyword, next) ->
        module.exports.searchIsbn client, keyword, (err, message) ->
            if err
                results.push err
                next()
                return
            results.push message.split('\n')[0]
            sleep 2000, next # next()を渡してはいけない
    , (err) ->
        callback err, results
