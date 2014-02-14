// Put your application scripts here
$(document).ready(function() {
    var text_max = 500;
    $('#dropit_count').html(text_max);

    $('#dropit_input').keyup(function() {
        var text_length = $('#dropit_input').val().length;
        var text_remaining = text_max - text_length;

        $('#dropit_count').html(text_remaining);
    });
});