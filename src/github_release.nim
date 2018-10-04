import ./cli

when isMainModule:

    import cligen
    import os

    dispatchMulti(
        [ upload ],
        [ create ],
        [ remove ],
        [ logs ],
        [ version ],
        # version = ("version", "github-release (" & version_string & ")")
    )
