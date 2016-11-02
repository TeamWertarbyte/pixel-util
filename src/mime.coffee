# Adapted from https://github.com/broofa/node-mime
#
# Copyright (c) 2010 Benjamin Thomas, Robert Kieffer
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

`
function Mime(db) {
  // Map of extension -> mime type
  this.types = Object.create(null);

  // Map of mime type -> extension
  this.extensions = Object.create(null);

  if (typeof db === 'object') {
    this.define(db);
    this.default_type = this.lookup('bin');
  }
}

/**
 * Define mimetype -> extension mappings.  Each key is a mime-type that maps
 * to an array of extensions associated with the type.  The first extension is
 * used as the default extension for the type.
 *
 * e.g. mime.define({'audio/ogg', ['oga', 'ogg', 'spx']});
 *
 * @param map (Object) type definitions
 */
Mime.prototype.define = function (map) {
  for (var type in map) {
    var exts = map[type];
    if (!Array.isArray(exts) && exts.extensions) {
      exts = exts.extensions;
    }
    for (var i = 0; i < exts.length; i++) {
      if (process.env.DEBUG_MIME && this.types[exts]) {
        console.warn(this._loading.replace(/.*\//, ''), 'changes "' + exts[i] + '" extension type from ' +
          this.types[exts] + ' to ' + type);
      }

      this.types[exts[i]] = type;
    }

    // Default extension is the first one we encounter
    if (!this.extensions[type]) {
      this.extensions[type] = exts[0];
    }
  }
};

/**
 * Lookup a mime type based on extension
 */
Mime.prototype.lookup = function(path, fallback) {
  var ext = path.replace(/.*[\.\/\\]/, '').toLowerCase();

  return this.types[ext] || fallback || this.default_type;
};

/**
 * Return file extension associated with a mime type
 */
Mime.prototype.extension = function(mimeType) {
  var type = mimeType.match(/^\s*([^;\s]*)(?:;|\s|$)/)[1].toLowerCase();
  return this.extensions[type];
};

/**
 * Return all MIME types which matching a pattern
 */
Mime.prototype.glob = function (pattern) {
  if (pattern == '*/*')
    return ['application/octet-stream'];

  var slashIdx = pattern.indexOf('/');
  if (slashIdx == -1 || pattern.slice(slashIdx + 1) !== "*")
    return [pattern];

  var prefix = pattern.slice(0,slashIdx+1);
  var result = [];
  var keys = Object.keys(this.extensions);
  keys.forEach(function (name) {
    if (name.slice(0, slashIdx+1) === prefix)
      result.push(name);
  })
  return result;
}

/**
 * Lookup a charset based on mime type.
 */
Mime.prototype.charsets = {
  lookup: function(mimeType, fallback) {
    // Assume text types are utf8
    return (/^text\//).test(mimeType) ? 'UTF-8' : fallback;
  }
};

module.exports = Mime;
`