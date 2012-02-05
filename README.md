# Node.js - LogMeUp

## About

LogMeUp is logger software. The difference between LogMeUp and other logging solutions is that with LogMeUp you can view your log files real-time in the web browser all over the world.

This is a Node.js REST api wrapper for LogMeUp Server (http://logmeup.com). Vist http://logmeup.com to learn about setting it up.


## Install

    npm install logmeup

## Using

To create a log file to start logging to, you must create a LogMeUp `collection`/`app` pair.

If you're developing an app named 'Slick Server' and you worked for the company 'Crab Shack', you might name your app `slickserver` and your collection `crabshack`.

### Methods/Properties

#### createLogger(params)

Creates an instance of a LogMeUp object. Valid input parameters are:

* host - LogMeUp host
* port - LogMeUp port, typically 7070
* collection - The name of your collection
* app - The name of your app
* autocreate - (Optional) recommend, Calling the `create()` method isn't needed if this flag is set.


#### create(callback)

Creates a log file. Callback parameters:

* error - null if no error
* body - body text from server, null if error


#### delete(callback)

Deletes a log file. Callback parameters:

* error - null if no error
* body - body text from server, null if error


#### logExists

Is always set to **false** after a LogMeUp object is instantiated or created. Once a `create()` is called, it's set to **true**. If `autocreate` is set to **true**, then `create()` is implicitly called and `logExists` will be set to true. Calling `delete()` will set this to **false**.


#### log(data,[callback])

Logs data. Data can be a string for an object. Callback isn't necessary, but may be used for troubleshooting. Callback parameters:

* error - null if no error
* body - body text from server, null if error


### Example: Creating Logger

```javascript
var LogMeUp = require('logmeup').LogMeUp
var logger = LogMeUp.createLogger({host: "mylogmeupserver.com", port: 7070, collection: "crabshack", app: "slickserver", autocreate: true});
```

**Note:** Setting `autocreate` to `true` will prevent you from having to call `create()` before you start logging.

### Example: Logging Data

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
	"autocreate": true
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

MIT License. See [LICENSE][license] for complete details.

Copyright (c) 2012 JP Richardson [Twitter][twitter] / [Google+][googleplus]



[license]:https://github.com/jprichardson/node-logmeup/blob/master/LICENSE
[logmeup]:http://logmeup.com
[gitpilot]:http://gitpilot.com
[twitter]:http://twitter.com/jprichardson
[googleplus]:https://plus.google.com/u/0/117996975742030675047/posts  










