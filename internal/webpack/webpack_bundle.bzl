### Reusable stuff

WEBPACK_BUNDLE_ATTRS = {
    "srcs": attr.label_list(
        doc = "JavaScript source files",
        allow_files = [".js"]),
    "entry_point": attr.string(mandatory = True),
    "_webpack": attr.label(
        default=Label("//internal/webpack:webpack-cli"),
        executable=True,
        cfg="host"),
    "_webpack_config_template": attr.label(
        default = Label("//internal/webpack:webpack.config.tmpl.js"),
        allow_single_file = True),
}

WEBPACK_BUNDLE_OUTPUTS = {
    # FIXME: outputs shouldn't be named after the target
    "bundle": "%{name}.js",
    "webpack_config": "_%{name}_webpack.config.js"
}

# TODO: don't take the whole context here
def run_webpack(ctx, sources, output, entry_point):

  ctx.actions.expand_template(
      template=ctx.file._webpack_config_template,
      output=ctx.outputs.webpack_config,
      substitutions={
          "TEMPLATED_entry_point": entry_point,
          "TEMPLATED_name": ctx.attr.name, # FIXME: should user control it
          "TEMPLATED_output": output.path,
          "TEMPLATED_mode": "production", # TODO or development
      },
  )

  webpack_args = ctx.actions.args()
  webpack_args.add(["--config", ctx.outputs.webpack_config.path])

  ctx.actions.run(
    progress_message = "Webpack bundling %s" % ctx.label,
    inputs = sources + [ctx.outputs.webpack_config],
    outputs = [output],
    executable = ctx.executable._webpack,
    arguments = [webpack_args],
  )
  return output

### Our specific implementation

def _webpack_bundle(ctx):
  run_webpack(ctx, ctx.files.srcs, ctx.outputs.bundle, ctx.attr.entry_point)
  return [DefaultInfo(files = depset([ctx.outputs.bundle]))]

webpack_bundle = rule(
  implementation = _webpack_bundle,
  attrs = WEBPACK_BUNDLE_ATTRS,
  outputs = WEBPACK_BUNDLE_OUTPUTS,
)
