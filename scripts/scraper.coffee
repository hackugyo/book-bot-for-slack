module.exports.fetchLog = (userId, password, callback) ->
    client = require('cheerio-httpcli')
    cheerio = require('cheerio')

    url = 'https://www.taitocity.net/taito-opac/index.jsp'
    client.fetch(url)
    .then (result) ->
      loginInfo = {
        USERID: userId,
        PASSWORD: password
      }
      result.$('form[name=LOGIN]').submit loginInfo, (err, $, res, body) ->
        client.fetch('https://www.taitocity.net/taito-opac/OPP1000')
        .then (result) ->
            # /html/body/table[2]/tbody/tr/td/table/tbody/tr[2]/td/form[1]/table/tbody/tr/td/table/tbody/tr[2..10]/td[6]
            inXpath = "body/table[2]/tr/td/table/tr[2]/td/form[1]/table/tr/td/table"
            xpath = inXpath.split( "/" );
            dom_body = cheerio.load(result.body);
            sss = dom_body('*');
            for child, i in xpath
                if (xpath[i].indexOf('[') == -1)
                    sss = sss.children(xpath[i])
                else
                    selector = xpath[i].split('[')[0];
                    matches = xpath[i].match(/\[(.*?)\]/);
                    index = matches[1] - 1;
                    sss = sss.children(selector).eq(index)
            results = []
            for i in [1..10]
                sssInner = sss.children('tr').eq(i)
                sssInner = sssInner.children('td').eq(5)
                utf8encodedString = sssInner.html().trim()
                replacer = "&#x"
                utf8encodedString = utf8encodedString.replace(///#{replacer}///g, "\\u").replace(/;/g, "")
                regex = /\\u([\d\w]{4})/gi;
                str = utf8encodedString.replace regex,  (match, grp) ->
                    return String.fromCharCode(parseInt(grp, 16))
                str = unescape(str)
                results.push str

            callback null, results