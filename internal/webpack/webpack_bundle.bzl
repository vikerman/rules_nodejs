### Reusable stuff

WEBPACK_BUNDLE_ATTRS = {
    "srcs": attr.label_list(allow_files = True),
    "_webpack": attr.label(
        default=Label("//internal/webpack:webpack-cli"),
        executable=True,
        cfg="host"),

}
WEBPACK_BUNDLE_OUTPUTS = {
    # FIXME: outputs shouldn't be named after the target
    "bundle": "%{name}.js",
    #"webpack_config": "_%{name}_webpack.config.js"
}

# TODO: don't take the whole context here
def run_webpack(ctx, sources, output):
  ctx.actions.run(
    progress_message = "Webpack bundling %s" % ctx.label,
    inputs = sources,
    outputs = [output],
    executable = ctx.executable._webpack,
  )
  return output

### Our specific implementation

def _webpack_bundle(ctx):
  run_webpack(ctx, ctx.attr.srcs, ctx.outputs.bundle)
  return [DefaultInfo(files = depset([ctx.outputs.bundle]))]

webpack_bundle = rule(
  implementation = _webpack_bundle,
  attrs = WEBPACK_BUNDLE_ATTRS,
  outputs = WEBPACK_BUNDLE_OUTPUTS,
)
