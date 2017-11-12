const webpack = require('webpack');
const path = require('path');

module.exports = [
  {
    entry: './src/js/bootstrap.js',
    output: {
      path: path.resolve(__dirname, 'static/js'),
      publicPath: "/static/js/",
      filename: 'bundle.js',
    },
    module: {
      loaders: [
        {
          test: /\.tag$/,
          enforce: "pre",
          exclude: /node_modules/,
          loader: 'riot-tag-loader',
          query: {
            hot: true,
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
    plugins: [
      new webpack.ProvidePlugin({ riot: 'riot' }),
    ],
    devServer: {
      port: 3000,
    },
  },
];
