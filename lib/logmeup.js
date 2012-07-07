(function() {
  var EventEmitter, LogMeUp, defaultLogger, exports, fs, path, request,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  request = require('superagent');

  path = require('path');

  fs = require('fs');

  EventEmitter = require('events').EventEmitter;

  require('string');

  exports = module.exports;

  defaultLogger = null;

  LogMeUp = (function(_super) {

    __extends(LogMeUp, _super);

    LogMeUp.prototype.logExists = false;

    LogMeUp.prototype.logsPending = 0;

    function LogMeUp(baseUrl, collection, app, autocreate) {
      this.baseUrl = baseUrl;
      this.collection = collection;
      this.app = app;
      this.autocreate = autocreate;
      this.log = __bind(this.log, this);
    }

    LogMeUp.prototype.create = function(callback) {
      var url,
        _this = this;
      url = "" + this.baseUrl + "/log/" + this.collection + "/" + this.app;
      return request.put(url).end(function(res) {
        if (res.text.startsWith("Error:") || res.status !== 200) {
          if (res.text.contains('exists')) _this.logExists = true;
          return callback(new Error(res.text), null);
        } else {
          _this.logExists = true;
          return callback(null, res.text);
        }
      });
    };

    LogMeUp.prototype["delete"] = function(callback) {
      var url,
        _this = this;
      url = "" + this.baseUrl + "/log/" + this.collection + "/" + this.app;
      return request.del(url).end(function(res) {
        if (res.text.startsWith("Error:") || res.status !== 200) {
          return callback(new Error(res.text), null);
        } else {
          _this.logExists = false;
          return callback(null, res.text);
        }
      });
    };

    LogMeUp.prototype.log = function(data, callback) {
      var logData, mime, newData, url,
        _this = this;
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
      this.logsPending += 1;
      logData = function() {
        return request.post(url).set('Content-Type', mime).send(newData).end(function(res) {
          _this.logsPending -= 1;
          if (res.text.startsWith("Error:") || res.status !== 200) {
            return typeof callback === "function" ? callback(new Error(res.text), null) : void 0;
          } else {
            return typeof callback === "function" ? callback(null, res.text) : void 0;
          }
        });
      };
      if (!this.autocreate || this.logExists) {
        return logData();
      } else {
        return this.create(function() {
          return logData();
        });
      }
    };

    LogMeUp.createLogger = function(params) {
      var autocreate, baseUrl;
      if (params == null) params = {};
      autocreate = params.autocreate || (params.autocreate = false);
      baseUrl = "http://" + params.host + ":" + params.port;
      return new LogMeUp(baseUrl, params.collection, params.app, autocreate);
    };

    LogMeUp.loadDefault = function() {
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
        if (fs.existsSync(p)) {
          config = JSON.parse(fs.readFileSync(p));
          defaultLogger = LogMeUp.createLogger(config);
        }
      }
      return defaultLogger;
    };

    return LogMeUp;

  })(EventEmitter);

  LogMeUp.loadDefault();

  exports.LogMeUp = LogMeUp;

  exports["default"] = defaultLogger;

}).call(this);
