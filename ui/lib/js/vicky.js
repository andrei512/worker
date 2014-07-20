var clientId = '598122546966-aeoj24o1qr5gqg6mmqfq4e5k51spddcl.apps.googleusercontent.com';

var apiKey = 'AIzaSyCTeuyuYjzxpI73pRI1TcZTOA05EykD1fk';

var scopes = 'https://www.googleapis.com/auth/youtube.readonly';

function handleClientLoad() {
    debugger
  // Step 2: Reference the API key
  gapi.client.setApiKey(apiKey);
  window.setTimeout(checkAuth,1);
}

function checkAuth() {
    debugger
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, handleAuthResult);
}

function handleAuthResult(authResult) {
    debugger
  var authorizeButton = document.getElementById('authorize-button');
  console.log(authResult)
  if (authResult && !authResult.error) {
    authorizeButton.style.visibility = 'hidden';
    makeApiCall();
  } else {
    authorizeButton.style.visibility = '';
    authorizeButton.onclick = handleAuthClick;
  }
}

function handleAuthClick(event) {
  // Step 3: get authorization to use private data
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, handleAuthResult);
  return false;
}

// Load the API and make an API call.  Display the results on the screen.
function makeApiCall() {
  // Step 4: Load the Google+ API
  gapi.client.load('youtube', 'v3', function() {
    // Step 5: Assemble the API request
    var request = gapi.client.youtube.search.list({
      'q': 'tool',
      'part': 'snippet',
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