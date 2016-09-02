var path = require("path");
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ],
    "vendor": [
      "!!script!jquery/dist/jquery.min.js",
      "!!script!foundation-sites/dist/foundation.min.js",
      "!!script!motion-ui/dist/motion-ui.min.js"
    ]
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js',
  },
  externals: {
    jquery: "jQuery"
  },
  module: {
    loaders: [
      {
        test: /\.(css|scss)$/,
        loaders: [
          'style-loader',
          'css-loader',
        ]
      },
      {
        test:    /\.html$/,
        exclude: /node_modules/,
        loader:  'file?name=[name].[ext]',
      },
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack',
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff',
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader',
      },
    ],

    noParse: /\.elm$/,
  },
  sassLoader: {
    includePaths: [path.resolve(__dirname, "node_modules")]
  },
  devServer: {
    inline: true,
    stats: { colors: true },
  },
  plugins: [
    new CopyWebpackPlugin([ { from: './src/data.json' } ])
  ]

};
