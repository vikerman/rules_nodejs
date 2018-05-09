const webpack = require('webpack');

var webpackConfig = {
  mode: 'TEMPLATED_mode',
  entry: {
    'TEMPLATED_name': './TEMPLATED_entry_point',
  },
  resolve: {
    modules: ['src', 'node_modules']

  },
  output: {path: `${process.cwd()}/TEMPLATED_output`}
};

module.exports = webpackConfig;
