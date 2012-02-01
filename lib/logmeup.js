(function() {
  var Logmeup, defaultLogger, exports, fs, path, request;

  request = require('superagent');

  path = require('path');

  fs = require('fs');

  require('string');

  exports = module.exports;

  defaultLogger = null;

  Logmeup = (function() {

    function Logmeup(baseUrl, collection, app) {
      this.baseUrl = baseUrl;
      this.collection = collection;
      this.app = app;
    }

    Logmeup.prototype.create = function(callback) {
      var url;
      url = "" + this.baseUrl + "/log/" + this.collection + "/" + this.app;
      return request.put(url).end(function(res) {
        if (res.text.startsWith("Error:") || res.status !== 200) {
          return callback(new Error(res.text), null);
        } else {
          return callback(null, res.text);
        }
      });
    };

    Logmeup.prototype["delete"] = function(callback) {
      var url;
      url = "" + this.baseUrl + "/log/" + this.collection + "/" + this.app;
      return request.del(url).end(function(res) {
        if (res.text.startsWith("Error:") || res.status !== 200) {
          return callback(new Error(res.text), null);
        } else {
          return callback(null, res.text);
        }
      });
    };

    Logmeup.prototype.log = function(data, callback) {
      var mime, newData, url;
      url = "" + this.baseUrl + "/log/" + this.collection + "/" + this.app;
      newData = null;
      mime = '';
      if (typeof data === 'object') {
        newData = data;
        mime = 'application/json';
      } else {
        try {
          newData = JSON.parse(data);
          mime = 'application/json';
        } catch (error) {
          newData = {
            data: data
          };
          mime = 'application/x-www-form-urlencoded';
        }
      }
      return request.post(url).set('Content-Type', mime).send(newData).end(function(res) {
        if (res.text.startsWith("Error:") || res.status !== 200) {
          if (callback != null) callback(new Error(res.text), null);
        } else {
          if (callback != null) return callback(null, res.text);
        }
      });
    };

    Logmeup.createLogger = function(params) {
      var baseUrl;
      if (params == null) params = {};
      baseUrl = "http://" + params.host + ":" + params.port;
      return new Logmeup(baseUrl, params.collection, params.app);
    };

    Logmeup.loadDefault = function() {
      var config, configFiles, dir, dirs, file, p, paths, _i, _j, _k, _len, _len2, _len3;
      if (defaultLogger != null) return defaultLogger;
      configFiles = ['logmeup.json'];
      dirs = ['./', './config/'];
      paths = [];
      for (_i = 0, _len = dirs.length; _i < _len; _i++) {
        dir = dirs[_i];
        for (_j = 0, _len2 = configFiles.length; _j < _len2; _j++) {
          file = configFiles[_j];
          paths.push(path.join(process.cwd(), dir, file));
          paths.push(path.join(__dirname, file));
        }
      }
      for (_k = 0, _len3 = paths.length; _k < _len3; _k++) {
        p = paths[_k];
        if (path.existsSync(p)) {
          config = JSON.parse(fs.readFileSync(p));
          defaultLogger = Logmeup.createLogger(config);
        }
      }
      return defaultLogger;
    };

    return Logmeup;

  })();

  Logmeup.loadDefault();

  exports.Logmeup = Logmeup;

  exports["default"] = defaultLogger;

}).call(this);
