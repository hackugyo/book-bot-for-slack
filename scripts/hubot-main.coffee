# https://gist.github.com/ta9to/a990100e85a6a909aa3e
# require('date-utils');

module.exports = (robot) ->
  robot.hear /^amazon (.*)/i, (msg) ->
    keyword = "#{msg.match[1]}"
    msg.send "http://www.amazon.co.jp/s/ref=nb_sb_noss_2?field-keywords=#{keyword}"

  # Trelloに追加
  robot.hear /^want (.*)/i, (msg) ->
    title = "#{msg.match[1]}"

    Trello = require("node-trello")
    t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
    t.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_LIST}, (err, data) ->
      if err
        msg.send "ERROR"
        return
      msg.send "「#{title}」 をTrelloに保存しました"

  # AmazonからISBNを拾う
  robot.hear /^get_isbn (.*)/i, (msg) ->
    keyword = "#{msg.match[1]}"
    amazonIsbnSearcher = require('./amazon-isbn-search.coffee')
    amazon = require('amazon-product-api')
    client = amazon.createClient({
        awsId:     process.env.AMAZON_AWS_ID,
        awsSecret: process.env.AMAZON_AWS_SECRET,
        awsTag:    process.env.AMAZON_AWS_TAG,
    })
    amazonIsbnSearcher.searchIsbn client, keyword, (err, message) ->
        if err
            msg.send(err)
        msg.send(message)

  # 図書館から借りているものをフェッチ
  robot.hear /^fetch_lib/i, (msg) ->
    scraper = require('./scraper.coffee')
    scraperShibuya = require('./scraper_shibuya.coffee')
    amazonIsbnSearcher = require('./amazon-isbn-search.coffee')
    amazon = require('amazon-product-api')
    client = amazon.createClient({
        awsId:     process.env.AMAZON_AWS_ID,
        awsSecret: process.env.AMAZON_AWS_SECRET,
        awsTag:    process.env.AMAZON_AWS_TAG,
    })
    scraper.fetchLog process.env.LIBRARY_ID_TAITO, process.env.LIBRARY_PASSWORD_TAITO, (err, results) ->
        if err
            msg.send err
            return
        msg.send results.join('\n')
        amazonIsbnSearcher.searchIsbns client, results, (err, messages) ->
            if err
                msg.send(err)
                return
            message = messages.join('\n')
            msg.send(message)
            # 次は渋谷を攻める
            scraperShibuya.fetchShibuya process.env.LIBRARY_ID_SHIBUYA, process.env.LIBRARY_PASSWORD_SHIBUYA, (err, results) ->
                if err
                    msg.send err
                    return
                msg.send results.join('\n')
                amazonIsbnSearcher.searchIsbns client, results, (err, messages) ->
                    if err
                        msg.send(err)
                        return
                    message = messages.join('\n')
                    msg.send(message)