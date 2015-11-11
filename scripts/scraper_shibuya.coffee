module.exports.fetchShibuya = (userId, password, callback) ->
    client = require('cheerio-httpcli')
    cheerio = require('cheerio')

    url = "https://www.lib.city.shibuya.tokyo.jp/asp/WwJouNinshou.aspx"
    client.fetch(url)
    .then (result) ->
        # title = result.$('title').text().replace(/\n/g, '')

        loginInfo = {
            txtRiyoshaCD: userId,
            txtPassword: password
        }
        form = result.$('#Form1')
        result.$('form[name=Form1]').submit loginInfo,  (err, $, res, body) ->
            if !err && res.statusCode == 200
                # //*[@id="dgdKas"]/tbody/tr[2..11]/td[2]/a
                sss = $('#dgdKas')
                results = []
                for i in [1..10]
                    sssInner = sss.children('tr').eq(i)
                    sssInner = sssInner.children('td').eq(1)
                    sssInner = sssInner.children('a')
                    results.push sssInner.text()
                callback null, results
