# github-release

`github-release` is a command line utility tool that allows you to easily manage your releases on GitHub.
You can create releases, remove releases and upload files to existing releases using this tool.

![](./img/github-release.gif)

`github-release` uses [GitHub v3 API](http://developer.github.com/v3/repos/releases).

- [# Setup](#-setup)
- [# Create a release](#-create-a-release)
- [# Remove a release](#-remove-a-release)
- [# Upload a file to a release](#-upload-to-a-release)
- [# Documentation](#-documentation)

### # Setup

You can download the latest binaries from [here](https://github.com/kdheepak/github-release/releases). Binaries are available for Windows, Mac and Linux.
Additionally, you will need a GitHub Personal Access Token to manage your releases.
Go to [this page](https://github.com/settings/tokens) and click generate a new token, enter your password and select the necessary permissions. You may need just `repo` permissions on the token to manage your releases. Click Generate Token at the bottom of the screen and copy the token to a safe location. DO NOT SHARE THIS TOKEN ON THE INTERNET.

Once you've downloaded the binary, unzip it. On OSX for example, you can type the following in a command line to download and unzip the file.

```bash
curl -LO 'https://github.com/kdheepak/github-release/releases/download/v0.1.4/github-release-osx-amd64.tar.xz'
tar -xvf github-release-osx-amd64.tar.xz
```

You can run the command using the following:

```bash
./github-release-osx-amd64/github-release help
```

### # Create a release

The following will create a release named `v0.1.4` on a repo called `github-release` under the username `kdheepak` if it doesn't already exist.

```bash
github-release create -t $GITHUB_TOKEN -o kdheepak -r github-release --tag v0.1.4
```

Creating a release will also by default add a changelog based on all the commits from the previous tag to the most recent tag.

![](./img/screenshot-changelog.png)

You can specify any custom text by setting the `--body` flag in the command line.

### # Remove a release

The following will remove a release named `v0.1.4` on a repo called `github-release` under the username `kdheepak` if it exists.

```bash
github-release remove -t $GITHUB_TOKEN -o kdheepak -r github-release --tag v0.1.4
```

### # Upload to a release

The following will upload the `./bin/github-release` file to a release named `v0.1.4` on a repo called `github-release` under the username `kdheepak` if there is no file already that exists by the same name and if the tag / release already exists.

```
github-release upload -t $GITHUB_TOKEN -o kdheepak -r github-release --tag v0.1.4 --file ./bin/githubr-release
```

### # Documentation

```bash
Usage: github-release [global options] <verb> [verb options]

Global options:
        -h, --help           Show this help
        -v, --verbose        Be verbose
        -q, --quiet          Do not print anything, even errors (except if --verbose is specified)
            --version        Print version

Verbs:
    delete:
        -s, --security-token Github token (required if $GITHUB_TOKEN not set)
        -u, --user           Github repo user or organisation (required if $GITHUB_USER not set)
        -r, --repo           Github repo (required if $GITHUB_REPO not set)
        -t, --tag            Git tag of release to delete (*)
    download:
        -s, --security-token Github token ($GITHUB_TOKEN if set). required if repo is private.
        -u, --user           Github repo user or organisation (required if $GITHUB_USER not set)
        -r, --repo           Github repo (required if $GITHUB_REPO not set)
        -l, --latest         Download latest release (required if tag is not specified)
        -t, --tag            Git tag to download from (required if latest is not specified) (*)
        -n, --name           Name of the file (*)
    edit:
        -s, --security-token Github token (required if $GITHUB_TOKEN not set)
        -u, --user           Github repo user or organisation (required if $GITHUB_USER not set)
        -r, --repo           Github repo (required if $GITHUB_REPO not set)
        -t, --tag            Git tag to edit the release of (*)
        -n, --name           New name of the release (defaults to tag)
        -d, --description    New release description, use - for reading a description from stdin (defaults to tag)
            --draft          The release is a draft
        -p, --pre-release    The release is a pre-release
    info:
        -s, --security-token Github token ($GITHUB_TOKEN if set). required if repo is private.
        -u, --user           Github repo user or organisation (required if $GITHUB_USER not set)
        -r, --repo           Github repo (required if $GITHUB_REPO not set)
        -t, --tag            Git tag to query (optional)
        -j, --json           Emit info as JSON instead of text
    release:
        -s, --security-token Github token (required if $GITHUB_TOKEN not set)
        -u, --user           Github repo user or organisation (required if $GITHUB_USER not set)
        -r, --repo           Github repo (required if $GITHUB_REPO not set)
        -t, --tag            Git tag to create a release from (*)
        -n, --name           Name of the release (defaults to tag)
        -d, --description    Release description, use - for reading a description from stdin (defaults to tag)
        -c, --target         Commit SHA or branch to create release of (defaults to the repository default branch)
            --draft          The release is a draft
        -p, --pre-release    The release is a pre-release
    upload:
        -s, --security-token Github token (required if $GITHUB_TOKEN not set)
        -u, --user           Github repo user or organisation (required if $GITHUB_USER not set)
        -r, --repo           Github repo (required if $GITHUB_REPO not set)
        -t, --tag            Git tag to upload to (*)
        -n, --name           Name of the file (*)
        -l, --label          Label (description) of the file
        -f, --file           File to upload (use - for stdin) (*)
        -R, --replace        Replace asset with same name if it already exists (WARNING: not atomic, failure to upload will remove the original asset too)
```
