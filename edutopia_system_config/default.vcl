backend default {
  .host = "127.0.0.1";
  .port = "8080";
  .connect_timeout = 600s;
  .first_byte_timeout = 600s;
  .between_bytes_timeout = 600s;
}

sub vcl_recv {
  if (req.request != "GET" &&
    req.request != "HEAD" &&
    req.request != "PUT" &&
    req.request != "POST" &&
    req.request != "TRACE" &&
    req.request != "OPTIONS" &&
    req.request != "DELETE") {
      /* Non-RFC2616 or CONNECT which is weird. */
      return (pipe);
  }

  if (req.request != "GET" && req.request != "HEAD") {
    /* We only deal with GET and HEAD by default */
    return (pass);
  }
  
  // skip binary files and just lookup in cache
  if (req.url ~ "\.(jpe?g|png|gif|ico|gz|tgz|bz2|tbz|mp3|ogg|swf|pdf)$") {
    unset req.http.cookie;
    return (lookup);
  }

  // Remove cookies:
  //   has_js:                     'has_js'
  //   Google Analytics/Quantcast: '__[a-z]+'
  //   Woopra:                     'woo[A-Za-z]+
  set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|has_js|woo[A-Za-z]+)=[^;]*", "");
  

  // To users: if you have additional cookies being set by your system (e.g.
  // from a javascript analytics file or similar) you will need to add VCL
  // at this point to strip these cookies from the req object, otherwise
  // Varnish will not cache the response. This is safe for cookies that your
  // backed (Drupal) doesn't process.
  //
  // Again, the common example is an analytics or other Javascript add-on.
  // You should do this here, before the other cookie stuff, or by adding
  // to the regular-expression above.


  // Remove a ";" prefix, if present.
  set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");
  // Remove empty cookies.
  if (req.http.Cookie ~ "^\s*$") {
    unset req.http.Cookie;
  }

  if (req.http.Authorization || req.http.Cookie) {
    /* Not cacheable by default */
    return (pass);
  }

  // Skip the Varnish cache for install, update, and cron
  if (req.url ~ "install\.php|update\.php|cron\.php") {
    return (pass);
  }

  // Normalize the Accept-Encoding header
  // as per: http://varnish-cache.org/wiki/FAQ/Compression
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpe?g|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
      # No point in compressing these
      remove req.http.Accept-Encoding;
    }
    elsif (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    }
    else {
      # Unknown or deflate algorithm
      remove req.http.Accept-Encoding;
    }
  }

  // Let's have a little grace
  set req.grace = 30s;

  return (lookup);
}

 sub vcl_hash {
   if (req.http.Cookie) {
     set req.hash += req.http.Cookie;
   }
 }

 // Strip any cookies before an image/js/css is inserted into cache.
 sub vcl_fetch {
   if (req.url ~ "\.(jpe?g|png|gif|ico|gz|tgz|bz2|tbz|mp3|ogg|swf|pdf)$") {
     // This is for Varnish 2.0; replace obj with beresp if you're running
     // Varnish 2.1 or later.
     unset beresp.http.set-cookie;
   }
 }

 sub vcl_error {
   // Let's deliver a friendlier error page.
   // You can customize this as you wish.
   set obj.http.Content-Type = "text/html; charset=utf-8";
   synthetic {"
   <?xml version="1.0" encoding="utf-8"?>
   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
   <html>
     <head>
       <title>"} obj.status " " obj.response {"</title>
       <style type="text/css">
       #page {width: 400px; padding: 10px; margin: 20px auto; border: 1px solid black; background-color: #FFF;}
       p {margin-left:20px;}
       body {background-color: #DDD; margin: auto;}
       </style>
     </head>
     <body>
     <div id="page">
     <h1>Page Could Not Be Loaded</h1>
     <p>We're very sorry, but the page could not be loaded properly. This should be fixed very soon, and we apologize for any inconvenience.</p>
     <hr />     <h4>Debug Info:</h4>
     <pre>
 Status: "} obj.status {"
 Response: "} obj.response {"
 XID: "} req.xid {"
 </pre>
       <address><a href="http://www.varnish-cache.org/">Varnish</a></address>
       </div>
     </body>
    </html>
    "};
    return(deliver);
 }
