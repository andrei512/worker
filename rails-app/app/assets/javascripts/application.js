// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

$(function(){
    $(document).foundation();

    $(window).load( function() {

        // Load Google API key
        var apiKey = 'AIzaSyD9b0JYMU2vbjmNGhNyhYXZflQMjMU5aPs';
        gapi.client.setApiKey(apiKey);
    });
});

var LINK = "http://andrei512.no-ip.biz/run.json"

function makeYoutubeCall(input, callback) {
    gapi.client.load('youtube', 'v3', function() {
        var request = gapi.client.youtube.search.list({
            'q': input,
            'part': 'snippet',
            'fields': 'items(id,snippet)'
        });

        request.execute(callback);
    });
}

var suggestionLinkClick = function(event) {
    event.preventDefault();
    $.ajax( this.href, {
        method: 'post',
        data: $(this).attr('value'),
        success: function() {
        },
        error: function() {
            console.log("Error")
        }
    })
}

$('#youtube-input').bind("enterKey",function(e){
    var input = this.value
    var params = {
        'task': "youtube"
    }
    makeYoutubeCall(input, function(response) {
        if (!response || response === undefined) {
            return undefined;
        }

        html = "";
        console.log(response)
        $(response.items).each( function() {
            params['message'] = this.snippet.title;
            var vals = "params=" + JSON.stringify(params);

            html += "<li> <a class='suggestion-link' href='" + LINK + "' value='" + vals + "'>" + this.snippet.title + "</a></li>";
        });
        $('#youtube-results').html(html);
        $('.suggestion-link').click(suggestionLinkClick);
    });
});
$('#youtube-input').keyup(function(e){
    if(e.keyCode == 13)
    {
        $(this).trigger("enterKey");
    }
});