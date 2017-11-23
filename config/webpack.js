const path = require('path');
const webpack = require('webpack');
const UglifyEsPlugin = require('uglify-es-webpack-plugin');

module.exports.webpack = {
  options: {
    entry: path.resolve(__dirname, '../frontend/src/js/bootstrap.js'),
    output: {
      path: path.resolve(__dirname, '../assets/js/'),
      filename: 'bundle.js',
      publicPath: '/'
    },
    module: {
      loaders: [
        {
          test: /\.tag$/,
          enforce: "pre",
          exclude: /node_modules/,
          loader: 'riot-tag-loader',
          query: {
            hot: false,
          }
        },
        {
          test: /\.js|\.tag$/,
          enforce: "post",
          exclude: /node_modules/,
          loader: 'babel-loader',
          query: {
            presets: `es2015-riot`,
          },
        },
      ],
    },
    resolve: {
      extensions: ['.js', '.tag'],
    },
  },
  server: {
    port: 1338,
    hot: true,
    inline: true,
  },
  production: {
    plugins: [
      new webpack.ProvidePlugin({ riot: 'riot' }),
      new UglifyEsPlugin(),
    ],
  },
  development: {
    plugins: [
      new webpack.ProvidePlugin({ riot: 'riot' }),
      //new webpack.HotModuleReplacementPlugin(),
    ]
  }
};
