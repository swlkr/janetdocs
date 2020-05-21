document.addEventListener('turbolinks:load', function() {
  document.querySelectorAll('pre code').forEach((block) => {
    hljs.highlightBlock(block);
  });
});

function highlight() {
  document.querySelectorAll('pre code').forEach((block) => {
    hljs.highlightBlock(block);
  });
}

function api(url, options) {
  var options = options || {};
  options.headers = options.headers || {};
  if(options.method.toLowerCase() !== 'get') {
    options['headers']['x-csrf-token'] = document.querySelector('meta[name="csrf-token"]').content;
  }
  options['headers']['x-requested-with'] = 'XMLHttpRequest'

  return fetch(url, options);
}


async function get(url, contentType) {
  var options = {
    method: 'get',
    headers: {
      'content-type': 'application/json'
    }
  };

  var response = await api(url, options);
  if(contentType === "text/html") {
    return await response.text();
  } else {
    return await response.json();
  }
}


async function post(url, body, contentType) {
  var options = {
    method: 'post',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify(body)
  };

  var response = await api(url, options);
  if(contentType === "text/html") {
    return await response.text();
  } else {
    return await response.json();
  }
}


function searcher(url) {
  return {
    token: '',
    results: '',

    search: async function() {
      var html = await post(url, { token: this.token }, "text/html");
      this.results = html;

      setTimeout(function() {
        document.querySelectorAll('pre > code').forEach(function(el) {
          hljs.highlightBlock(el);
        });
      }, 0)
    },

    go: function() {
      Turbolinks.visit(document.querySelectorAll('.binding')[0].getAttribute('href'))
    }
  }
}
