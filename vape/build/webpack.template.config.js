const webpack = require('webpack')
const merge = require('webpack-merge')
const base = require('./webpack.base.config')
const nodeExternals = require('webpack-node-externals')

const config = merge(base, {
  target: 'node',
  entry: './templates/index.js',
  output: {
    filename: 'templates.js',
    libraryTarget: 'commonjs2'
  },
  externals: nodeExternals({
    // do not externalize CSS files in case we need to import it from a dep
    whitelist: /(\.css|\.scss)$/
  }),
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
      'process.env.VUE_ENV': '"server"'
    }),
  ]
})

module.exports = config
