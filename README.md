# github-release

```bash
Usage:
  github-release subcommand [subcommand-opts & args]
where subcommand syntaxes are as follows:

  upload [required&optional-params]
    Options(opt-arg sep :|=|spc):
      -h, --help                       write this help to stdout
      -t=, --token=  string  REQUIRED  set token
      -o=, --owner=  string  REQUIRED  set owner
      -r=, --repo=   string  REQUIRED  set repo
      -f=, --file=   string  REQUIRED  set file
      --tag=         string  REQUIRED  set tag

  create [required&optional-params]
    Options(opt-arg sep :|=|spc):
      -h, --help                          write this help to stdout
      -t=, --token=     string  REQUIRED  set token
      -o=, --owner=     string  REQUIRED  set owner
      -r=, --repo=      string  REQUIRED  set repo
      --tag=            string  REQUIRED  set tag
      --target_commit=  string  "master"  set target_commit
      -n=, --name=      string  ""        set name
      -b=, --body=      string  ""        set body
      -d, --draft       bool    false     set draft
      -p, --prerelease  bool    false     set prerelease

  delete_release [required&optional-params]
    Options(opt-arg sep :|=|spc):
      -h, --help                       write this help to stdout
      -t=, --token=  string  REQUIRED  set token
      -o=, --owner=  string  REQUIRED  set owner
      -r=, --repo=   string  REQUIRED  set repo
      --tag=         string  REQUIRED  set tag
```
