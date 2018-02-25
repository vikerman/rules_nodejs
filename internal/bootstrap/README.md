# Bootstrap

The bootstrap workspace provides the nodejs, npm, and yarn binaries.
Users have to put this in their WORKSPACE manually to get started.

Importantly, there is very little code here, so we should rarely need to
ask users to update the version or sha256 in their WORKSPACE file.

# Developing

To publish this package, go to another branch and move these bootstrap files
to the root, and rename `ext.WORKSPACE` to `WORKSPACE`

TODO(alexeagle): some release automation for this
