proc main(token: string, owner: string, repo: string, file: string, tag: string): int =
    return 0


when isMainModule:

    import cligen
    import os
    const version_string = staticExec("git rev-parse --verify HEAD --short")

    dispatchGen(main, version = ("version", "glm (v0.1.0-dev " & versionString & ")"))

    if paramCount() == 0:
        discard dispatch_main(@["--version"])
        quit(dispatch_main(@["--help"]))
    else:
        quit(dispatch_main(commandLineParams()))
