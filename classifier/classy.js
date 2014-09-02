var natural = require('natural'),
  classifier = new natural.BayesClassifier(natural.PorterStemmerEs, null);
var Twit = require('twit');

var T = new Twit({
    consumer_key:         'bVqypJtXqUiiMH8d6FJd3A01w'
  , consumer_secret:      'UNK3wEZ1C5KA1DSrTC0v9smKPkRv2WTBgbZXKg4AcDwV6DiA3G'
  , access_token:         '17706291-lYhpVZTIJeUzlI03wpeA7CoCwl1wqyUeha2JZvRoz'
  , access_token_secret:  'YxMP10KKSaFujFMlGT4ykHBJ1rS5745CiMUlWgKJ3Y8Wz'
});

var bomba_phrases = ['Que mierda me importa quien se casa en Facebook',
						'Pero aún así y todo mi jefe insistió varias veces que quería acostarse conmigo y que no entendía por qué lo rechazaba.',
						'Que mierda me importa quien se casa en Facebook',
						'Mi vecina empezó a coger fuerte y me desperté por el ruido que hacía. Estaba babeando la almohada',
						'Todos los que se compraron zapatillas fluo te juro que se van a arrepentir.',
						'soy muy mala',
						'La amistad entre él y yo se terminó porque a él no se le paraba',
						'me esta haciendo cagar de frio en la calle',
						'Esta mal que me chupe todo un huevo',
						'Odio estar asi',
						'Que fea es la camiseta de atlanta no me gusta'];

for (var i = bomba_phrases.length - 1; i >= 0; i--) {
	classifier.addDocument(bomba_phrases[i], 'bomba');
};

var normal_phrases = ['El rock es una etapa que vas a pasar', 
						'Tanta cosa por hacer hoy en solo unas horas y yo tomando valor para meterme a bañar con agua fría',
						'4 Tweets retwitteados y un total de 5 RTs',
						'Si Lanata dice que Flor de la V es un hombre, no hay que dudar: si dice que hay inseguridad debe ser al revés',
						'Mis fans lo siguen intentando',
						'Llévame por china aunque vaya como sardina',
						'Sale a la disco a bailar una diva virtual',
						'Con luz en tela',
						'me hace cagar de risa lo amo',
						'Venezuela llegó al colmo y deberá importar petróleo',
						'nunca desistir',
						'Los abonados y socios tienen una semana más de plazo para comprar el adicional',
						'DIOSASSS que estarán en la pasarela VERANO2015',
						'yo también igual por ahí nos vemos en algún parador, estaría re bueno',
						'Fechas CONFIRMADAS',
						'Mi reina hermosa',
						'Yo soy de pueblo. Imagínate en esa red',
						'Ya falta poco para que termine el dia, y va a faltar menos para mi cumple',
						'Ancelotti. te hemos comprado el 9 que querías',
						'Este Miercoles va a estar con nosotros en el programa Chayanne',
						'Todos los osos de mi hermana tienen nombre',
						'Te amo mucho mi princesa',
						'Qué bien que anda Gallardo',
						'hola te acordas de mi? solías contarme todo',
						'Ay extrañaba esto :\')',
						'Conocé gente de todo el mundo ¡Participá y ganá!',
						'Juro que amo esta foto. Y a vos, más que nada!'];

for (var i = normal_phrases.length - 1; i >= 0; i--) {
	classifier.addDocument(normal_phrases[i], 'normal');
};


classifier.train();

classifier.save('classifier.json', function(err, classifier) {
    // the classifier is saved to the classifier.json file!
});

T.get('search/tweets', { geocode:'-34.6158527,-58.4332985,10mi', count: 500 }, function(err, data, response) {
  for (var i = data.statuses.length - 1; i >= 0; i--) {
  	tweet = data.statuses[i];
  	
  	if (classifier.classify(tweet.text) == 'bomba' && !hasNegativeWord(tweet.text)) {
  		console.log(tweet);
  	};
  };
});


var hasNegativeWord = function(tweet)
{
	var negative_keywords = ['sammywilkfollowspree'];
	for (var i = negative_keywords.length - 1; i >= 0; i--) {
		var nega = negative_keywords[i];
		if (tweet.indexOf(nega) > -1) { return true; };
	};
	return false;
}