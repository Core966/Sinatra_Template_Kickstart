$(document).ready(function() {
    $.ajaxSetup ({
        cache: false
    });

    var ajax_load = "<img src='/images/Loading-special.gif' alt='loading...' />";

    $("#load_comment").submit(function(ev){ // This is the new comment button of the post.
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
    
    $(document).on("click", 'a.comment-button', function(event) { // This is the edit button of the comment
      var classes = $(this).attr("class").split(" "); // First we separate the classes of this (anchor tag with comment button class) item
      var comment_class_id = classes[classes.length-1]; // Then we select the last class
      var comment_id = $("div." + comment_class_id).attr("id").split("-"); // Then we get the id of the class by seperating it by the "-" characters
      var comment_db_id = comment_id[comment_id.length-1]; // We select the last element.
      var comment_content = $("div." + comment_class_id).html(); // Then we get the content of the comment.
      $("div." + comment_class_id).html('<textarea id="edit-comment" name="comment[comment]" rows="3">' + comment_content + '</textarea>'); // Then we morph the comment to a text area filled with the given comment by selecting the same class the clicked anchor tag had.
      $("div#comment-button-id-" + comment_db_id).html('<input type="submit" class="pure-button" value="Submit Edited Comment" />'); // Then we change the comment edit button into a submit button.
    });

    $(document).on("submit", '#edit_comment', function(event) { // This is the submit edit button of the comment.
	event.preventDefault();
        var classes = $(this).attr("class").split(" "); // We separate the classes
        var comment_class_id = classes[classes.length-1]; // And then select the last one.
        var comment_id = comment_class_id.split("-"); // Then we get the comment ID.
        var comment_db_id = comment_id[comment_id.length-1]; // Of course we only need the number at the end.
	$.ajax({
            url: "/comments/" + comment_db_id, // Here we need the comment ID.
            data: $(this).serialize(),
            dataType: "html",
            success: function(data) {
              $('div#comments').html(data);
            }
        });
    });

    $(document).on("submit", '#delete_comment', function(event) { // This is the delete button of the comment
	event.preventDefault();
        var classes = $(this).attr("class").split(" "); // Same as above at the submit edit button.
        var comment_class_id = classes[classes.length-1];
        var comment_id = comment_class_id.split("-");
        var comment_db_id = comment_id[comment_id.length-1];
	$.ajax({
            url: "/comments/" + comment_db_id + "/delete",
            data: $(this).serialize(),
            dataType: "html",
            success: function(data) {
              $('div#comments').html(data);
            }
        });
    });

});
