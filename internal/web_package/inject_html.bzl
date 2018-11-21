def html_asset_inject(index_html, action_factory, injector, assets, output):
    args = action_factory.args()
    args.add(output.path)
    args.add(index_html.path)
    args.add_all(assets)
    args.use_param_file("%s", use_always=True)
    action_factory.run(
        inputs = [index_html],
        outputs = [output],
        executable = injector,
        arguments = [args],
    )
    return output

def _inject_html(ctx):
    output = ctx.actions.declare_file("index.html")
    html_asset_inject(ctx.file.index_html, ctx.actions, ctx.executable._injector,
        [f.path for f in ctx.files.assets] + ctx.attr.inject, output)
    return [
        DefaultInfo(files = depset([output]))
    ]

inject_html = rule(
    implementation = _inject_html,
    attrs = {
        "index_html": attr.label(allow_single_file=True),
        "assets": attr.label_list(
            allow_files=True,
            doc = """Files which should be referenced from the index_html""",
            default = [],
        ),
        "inject": attr.string_list(
            doc = """Assets to inject which don't have labels""",
            default = [],
        ),
         "_injector": attr.label(
            default = "@build_bazel_rules_nodejs//internal/web_package:injector",
            executable = True,
            cfg = "host",
        ),
    },
)
"""
Populates script tags and stylesheets into an html file.
"""