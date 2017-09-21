def _nodejs_module_impl(ctx):
  files = depset()
  files += ctx.files.srcs
  return [DefaultInfo(files = files)]

nodejs_module = rule(
    implementation = _nodejs_module_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        # Used to determine module mappings
        "module_name": attr.string(),
        "module_root": attr.string(),
    },
)
