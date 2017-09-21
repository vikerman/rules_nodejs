const helper = require('helper');

function main(args) {
  if (args.length < 1) helper.print("usage: arg1 arg2");
}

if (require.main === module) {
  process.exitCode = main(process.argv.slice(2));
}
