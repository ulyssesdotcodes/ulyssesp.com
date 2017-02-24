'use strict';

//import 'foundation-sites/dist/foundation-flex.min.css';
// require("font-awesome-webpack2");
// require('font-awesome-webpack!font-awesome-webpack/font-awesome.config.js');

require("!style-loader!css-loader!sass-loader!./styles.scss");

// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
var app = Elm.Main.embed(mountNode);
