# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Webpack bundling

The version of Webpack is controlled by the Bazel toolchain.
You do not need to install it into your project.
"""
load("//internal/common:collect_es6_sources.bzl", "collect_es6_sources")
load("//internal/common:module_mappings.bzl", "get_module_mappings")

WEBPACK_BUNDLE_ATTRS = {
    "srcs": attr.label_list(
        doc = "JavaScript source files",
        allow_files = [".js"]),
    "deps": attr.label_list(
        doc = "Other targets that produce JavaScript, e.g. `ts_library`"),
    "entry_point": attr.string(
        doc = "Entry point JS file, relative to the workspace root",
        mandatory = True),
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
    #"bundle": "%{name}.js",
}

def write_config(ctx, label, template, output_dir, entry_point, root_dir = None):
  config_file = ctx.actions.declare_file("_%s_webpack.config.js" % label.name)
  if not root_dir:
    build_file_dirname = "/".join(ctx.build_file_path.split("/")[:-1])
    root_dir = "/".join([ctx.bin_dir.path, build_file_dirname, ctx.label.name + ".es6"])

  ctx.actions.expand_template(
      template = template,
      output = config_file,
      substitutions = {
          "TMPL_entry_point": "/".join([".", root_dir, entry_point]),
          "TMPL_name": label.name, # FIXME: should user control it
          "TMPL_output": output_dir.path,
          "TMPL_mode": "production", # TODO or development
      },
  )
  return config_file

def run_webpack(actions, executable, label, sources, output_dir, config):
  webpack_args = actions.args()
  webpack_args.add(["--config", config.path])
  webpack_args.add(["--log-level", "error"])
  actions.run(
    progress_message = "Webpack bundling %s" % label,
    inputs = sources + [config],
    outputs = [output_dir],
    executable = executable._webpack,
    arguments = [webpack_args],
  )

####
# Our specific implementation
# If you want to customize your Webpack build, you can write your own .bzl file
# re-using everything above, similarly to what's done here, to create a rule
# like `my_rollup_bundle`

def _webpack_bundle(ctx):
  output_dir = ctx.actions.declare_directory(ctx.label.name + "_chunks")
  config = write_config(
      ctx,
      ctx.label,
      ctx.file._webpack_config_template,
      output_dir,
      ctx.attr.entry_point)
  run_webpack(
      ctx.actions,
      ctx.executable,
      ctx.label,
      collect_es6_sources(ctx),
      output_dir,
      config)
  return [DefaultInfo(files = depset([output_dir]))]

webpack_bundle = rule(
  implementation = _webpack_bundle,
  attrs = WEBPACK_BUNDLE_ATTRS,
  outputs = WEBPACK_BUNDLE_OUTPUTS,
)
"""Bundle JavaScript code into chunks using Webpack.

TODO(alexeagle): more docs
"""