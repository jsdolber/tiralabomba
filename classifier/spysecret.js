var request = require('request'); //.defaults({'proxy':'http://sebastiand:Copacabana15@wwppool.local.iadb.org:9090'});
var cheerio = require('cheerio');
var googleTranslate = require('google-translate')("AIzaSyAPGw69lQld2maqt9MIppYmBaBvZE4ywWE");
var util = require('util');

request('https://www.secret.ly', function (error, response, html) {
  if (!error && response.statusCode == 200) {
    $ = cheerio.load(html);
 	$(".collection-secret-message .center-fix").each(function() {
 		googleTranslate.translate($(this).text(), 'es', function(err, translation) {
		  console.log(translation.translatedText);
		  //console.log(util.inspect(err));
		  // =>  Mi nombre es Brandon
		});
 	});
  }
});