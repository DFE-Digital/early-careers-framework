const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production'
const path = require('path')
const webpack = require('webpack')

module.exports = {
  mode,
  devtool: 'source-map',
  entry: {
    application: [
      './app/assets/javascripts/application.js'
    ],
    sentry: [
      './app/assets/javascripts/sentry.js'
    ]
  },
  module: {
    rules: [
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg|ico)$/i,
        use: 'file-loader',
      },
    ],
  },
  output: {
    filename: '[name].js',
    sourceMapFilename: '[file].map',
    path: path.resolve(__dirname, 'app/assets/builds')
  },
  plugins: [
    // Include plugins
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
}
