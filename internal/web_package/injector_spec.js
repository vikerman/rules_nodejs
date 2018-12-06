const injector = require('./injector');
const fs = require('fs');
const path = require('path');

describe('HTML injector', () => {
  const inFile = 'some/index.html';
  const outFile = 'bazel-bin/some/index.html';

  let output;
  function read(file) {
    if (file === inFile) return `<html><head></head><body></body></html>`;
    throw new Error(`no content for ${file}`);
  }
  function write(_, content) {
    output = content;
  }

  it('should do be a no-op', () => {
    expect(injector.main([outFile, inFile], read, write)).toBe(0);
    expect(output).toBe('<html><head></head><body></body></html>');
  });

  it('should inject script tag', () => {
    expect(injector.main([outFile, inFile, 'path/to/my.js'], read, write)).toBe(0);
    expect(output).toBe(
        '<html><head></head><body><script type="text/javascript" src="/my.js"></script></body></html>');
  });

  it('should inject link tag', () => {
    expect(injector.main([outFile, inFile, 'path/to/my.css'], read, write)).toBe(0);
    expect(output).toBe(
        '<html><head><link rel="stylesheet" href="/my.css"></head><body></body></html>');
  });
});
