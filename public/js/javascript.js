$(document).ready(function() {
    $.ajaxSetup ({
        cache: false
    });

    var ajax_load = "<img src='/images/Loading-special.gif' alt='loading...' />";

    $("#load_post").submit(function(ev){
	ev.preventDefault();
	$.ajax({
            url: "/comments",
            data: $(this).serialize(),
            dataType: "html",
            success: function(data) {
              $('div#comments').html(data);
            }
        });
    });

    $("a.comment-button").click(function() {
      var classes = $(this).attr("class").split(" ");
      var comment_class_id = classes[classes.length-1];
      var comment_id = $("div." + comment_class_id).attr("id").split("-");
      var comment_db_id = comment_id[comment_id.length-1];
      var comment_content = $("div." + comment_class_id).html();
      $("div." + comment_class_id).html('<textarea id="edit-comment" name="comment[comment]" rows="3">' + comment_content + '</textarea>');
      $("div#comment-button-id-" + comment_db_id).html('<input type="submit" class="pure-button" value="Submit Edited Comment" />');
    });

    $("#edit_post").submit(function(ev){
	ev.preventDefault();
        var classes = $(this).attr("class").split(" ");
        var comment_class_id = classes[classes.length-1];
        var comment_id = comment_class_id.split("-");
        var comment_db_id = comment_id[comment_id.length-1];
	$.ajax({
            url: "/comments/" + comment_db_id,
            data: $(this).serialize(),
            dataType: "html",
            success: function(data) {
              $('div#comments').html(data);
            }
        });
    });

});

