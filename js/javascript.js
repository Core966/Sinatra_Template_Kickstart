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
});

