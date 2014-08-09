// Put your application scripts here
(function($){

  var url1 = /(^|&lt;|\s)(www\..+?\..+?)(\s|&gt;|$)/g,
      url2 = /(^|&lt;|\s)(((https?|ftp):\/\/|mailto:).+?)(\s|&gt;|$)/g,

      linkifyThis = function () {
        var childNodes = this.childNodes,
            i = childNodes.length;
        while(i--)
        {
          var n = childNodes[i];
          if (n.nodeType == 3) {
            var html = $.trim(n.nodeValue);
            if (html)
            {
              html = html.replace(/&/g, '&amp;')
                         .replace(/</g, '&lt;')
                         .replace(/>/g, '&gt;')
                         .replace(url1, '$1<a target="_blank" href="http://$2">$2</a>$3')
                         .replace(url2, '$1<a target="_blank" href="$2">$2</a>$5');
              $(n).after(html).remove();
            }
          }
          else if (n.nodeType == 1  &&  !/^(a|button|textarea)$/i.test(n.tagName)) {
            linkifyThis.call(n);
          }
        }
      };

  $.fn.linkify = function () {
    return this.each(linkifyThis);
  };

  $.fn.enterKey = function (fnc) {
    return this.each(function () {
        $(this).keypress(function (ev) {
            var keycode = (ev.keyCode ? ev.keyCode : ev.which);
            if (keycode == '13') {
                fnc.call(this, ev);
            }
        })
    })
}

})(jQuery);

$(document).ready(function() {
    var text_max = 500;

    $('#dropit_count').html(text_max);
    $(".btn-create").toggleClass('disabled');

    $('#dropit_input').keyup(function() {
        var text_length = $('#dropit_input').val().length;
        var text_remaining = text_max - text_length;

        if (text_remaining < 0)
        {
            $(".btn-create").addClass('disabled');
            $("#dropit_count").css('color', 'red');
        }            
        else
        {
            $(".btn-create").removeClass('disabled');
            $("#dropit_count").css('color', '#999');
        }

        if (text_length == 0) { $(".btn-create").addClass('disabled'); };
            
        $('#dropit_count').html(text_remaining);
    });

    $("#dropit_input").focus(function() {
        $(this).animate({
            height: 84
        }, "normal");
        $(".input-tag").show();
    }).blur(function() {
        if ($("#dropit_input").val().length == 0) {
            $(this).animate({
                height: 36
            }, "normal");
            $(".input-tag").hide();
        };
    });

    $(".btn-create").html('<i class="glyphicon glyphicon-fire" ></i>&nbspBoom');

    $('.vote').click(function(){
       var post_id = $(this).closest('.post').attr('id');
       var rating = $(this).attr('id');
       var el = $(this);
       $.post( "vote_post", { post_id: post_id, rating: parseInt(rating) + 1, authenticity_token: $("[name='authenticity_token']").val() }
        )
        .done(function() {
        })
        .fail(function() {
        })
        .always(function() {
            el.parent().find(".vote").css('color', 'black');
            for (var i = rating; i >= 0; i--) {
                el.parent().find(".vote#" + i).css('color', 'red');
            };

        });
    });

    var tweetParser = function(){
        $(".tweet-text").each(function()
        {
            var tokens = $(this).text().split(' ');

            for (var i = tokens.length - 1; i >= 0; i--) {
                var token = tokens[i];

                if (token.indexOf("@") == 0) {
                    var newToken = '<a href="http://twitter.com/' + token.replace("@", "") + '" target="_blank">' + token + "</a>";
                    var currentHtml = $(this).html().replace(token, newToken);
                    $(this).html(currentHtml);
                };

                if (token.indexOf("#") == 0) {
                    var newToken = '<a href="http://twitter.com/' + token + '" target="_blank">' + token + "</a>";
                    var currentHtml = $(this).html().replace(token, newToken);
                    $(this).html(currentHtml);
                };
            };
        });
    }

    $(".filter-n").click(function(){ location.href = '/?f=n'});
    $(".filter-p").click(function(){ location.href = '/?f=p'});

    $(".row.title").click(function (){
        location.href = '/';
    });

    $(".tweet").linkify();
    tweetParser();

    /*
    var category = getUrlVars()["c"];

    if (category === undefined || category.length == 0) 
    { $(".categories a").first().addClass('active'); }
    else {
      $(".categories a#" + category).first().addClass('active');
    }*/

    $('.multiselect').multiselect({buttonClass: 'btn btn-link', 
                                    nonSelectedText: 'agregar tags',
                                    numberDisplayed: 2,
                                    nSelectedText: 'seleccionados',
                                    onChange: function(element, checked) {
                                    if(checked == true) {
                                      // action taken here if true
                                      $("#categories").val($("#categories").val() + "," + element.val());
                                    }
                                    else {
                                        $("#categories").val($("#categories").val().replace(element.val(), ""));
                                    }                             
                                  }
                              });
    $(".input-tag").hide();

    // search
    $('#search-text').enterKey(function() { $('.btn-search').click() });
    $('.btn-search').click(function(){ 
        var searchEl = $('#search-text');

        if (searchEl.val().length > 0) {};
        location.href = '/search/' + searchEl.val();  });
});

function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}
