// Put your application scripts here
$(document).ready(function() {
    var text_max = 500;

    $('#dropit_count').html(text_max);

    $('#dropit_input').keyup(function() {
        var text_length = $('#dropit_input').val().length;
        var text_remaining = text_max - text_length;

        $('#dropit_count').html(text_remaining);
    });

    $(".button").html('<i class="glyphicon glyphicon-fire" ></i>&nbspBoom !');

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
            for (var i = rating; i >= 0; i--) {
                el.parent().find(".vote#" + i).css('color', 'red');
            };

        });
    });


});
