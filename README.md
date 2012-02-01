# Node.js - LogMeUp

## About

This is a Node.js REST api wrapper for LogMeUp Server (http://logmeup.com).

## Install

    npm install logmeup

## Using

To create a log file to start logging to, you must create a LogMeUp `collection`/`app` pair.

If you're developing an app named 'Slick Server' and you worked for the company 'Crab Shack', you might name your app `slickserver` and your collection `crabshack`.


### Creating Logger

```javascript
var Logmeup = require('logmeup');
var logger = Logmeup.createLogger({host: "mylogmeupserver.com", port: 7070, collection: "crabshack", app: "slickserver"});
```

### Logging Data

**These methods are asynchronous.**

```javascript

//log some JSON
logger.log({name: "JP", company: "Gitpilot"});

//log a string
logger.log("This is a really bad error!");

//optionally: inspect the servers response
logger.log("Bad error", function(error, responseText){
  console.log("The server said: " + responseText);
  if (err != null) {
    console.log("There was an error: " + err.message());
  }
});
```

### Default Logger

You can create a file named `logmeup.json` in the base directory of your application or in the `config/` folder of your app.

#### Configuration File

The configuration file should look like this:

```javascript
{
    "host": "yourlogmeupserver.com",
    "port": 7070,
    "collection": "gitpilotllc",
    "app": "server"
}
```

#### Using Default Logger

```javascript
//will autoload logmeup.json
//this way you can put this at the top of all your modules in your app without having to recreate the logger each time
var logger = require('logmeup').default;

logger.log("yay!!!");
```

## License

MIT License. See [LICENSE](license) for complete details.

Copyright (c) 2012 JP Richardson [Twitter](twitter) / [Google+](googleplus)



[license]:https://github.com/jprichardson/node-logmeup/blob/master/LICENSE
[logmeup]:http://logmeup.com
[gitpilot]:http://gitpilot.com
[twitter]:http://twitter.com/jprichardson
[googleplus]:https://plus.google.com/u/0/117996975742030675047/posts  










