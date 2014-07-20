
var apiKey = 'AIzaSyCTeuyuYjzxpI73pRI1TcZTOA05EykD1fk';

function handleClientLoad() {
  gapi.client.setApiKey(apiKey);
}

function makeApiCall() {
  gapi.client.load('youtube', 'v3', function() {
    var request = gapi.client.youtube.search.list({
      'q': 'tool',
      'part': 'snippet',
      'fields': 'items(id,snippet)'
    });

    // Step 6: Execute the API request
    request.execute(function(resp) {
    // var heading = document.createElement('h4');
    // var image = document.createElement('img');
    // image.src = resp.image.url;
    // heading.appendChild(image);
    // heading.appendChild(document.createTextNode(resp.displayName));

    // document.getElementById('content').appendChild(heading);
      console.log(resp)
    });
  });
}