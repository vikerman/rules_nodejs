const webpack = require('webpack');

var webpackConfig = {
  mode: 'TMPL_mode',
  entry: {
    'TMPL_name': 'TMPL_entry_point',
  },
  resolve: {modules: ['node_modules']},
  output: {path: `${process.cwd()}/TMPL_output`}
};

module.exports = webpackConfig;
