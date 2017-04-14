const webpack = require('webpack');
const path = require('path');

module.exports = {
  context: path.join(__dirname, 'src'),

  output: {
    path: path.join(__dirname, 'build')
  },

  plugins: [
    new webpack.SourceMapDevToolPlugin({
    })
  ],

  resolve: {
    modules: [
      path.resolve(__dirname, 'node_modules'),
      path.join(__dirname, './src')
    ],
    extensions: ['.js', '.coffee']
  },

  entry: {
    'bundles/app': path.join(__dirname, 'src/js/main.js'),
  },

  output: {
    path: path.join(__dirname, './build'),
    filename: '[name].bundle.js',
  },

  module: {
    rules: [
      {
        test: /\.coffee$/,
        loader: 'coffee-loader'
      }
    ],
  }
};
