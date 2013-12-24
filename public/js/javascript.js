$(document).ready(function() {
    $.ajaxSetup ({
        cache: false
    });

    var ajax_load = "<img src='/images/Loading-special.gif' alt='loading...' />";

    var loadUrl = "/comments";
    $("#load_post").submit(function(ev){
	ev.preventDefault();
        $("#result").html(ajax_load).load(loadUrl + " #comments");
    });

    $("a.comment-button").click(function() {
      var classes = $(this).attr("class").split(" ");
      var comment_class_id = classes[classes.length-1];
      var comment_id = $("div." + comment_class_id).attr("id").split("-");
      var comment_db_id = comment_id[comment_id.length-1];
      var comment_content = $("div." + comment_class_id).html();
      $("div." + comment_class_id).html('<textarea id="edit-comment" name="comment[comment]" rows="3">' + comment_content + '</textarea>');
    });

});

