import strutils
import strformat
import httpclient
import json
import mimetypes
import ospaths
import osproc

type
    Github* = ref object
        token: string
        owner: string
        repo: string
        hostname: string
    GithubError* = object of Exception
        code*: int
        body*: JsonNode

proc newGithub*(token: string, owner: string, repo: string): Github =
    let hostname = getEnv("GITHUB_HOSTNAME", "github")
    return Github(token: token, owner: owner, repo: repo, hostname: hostname)

proc request*(g: Github, url: string,
              httpMethod: string = "get", body = "",
              headers: HttpHeaders = nil): string =
    var client = newHttpClient()
    client.headers = newHttpHeaders({ "Authorization": fmt"token {g.token}" })
    var realurl: string
    if url.startsWith("/"):
        realurl = fmt"https://api.{g.hostname}.com/repos/{g.owner}/{g.repo}" & url
    else:
        realurl = url
    let response = client.request(realurl, httpMethod = httpMethod, body = body, headers = headers)
    let code = response.status.split(" ")[0].parseInt()
    if code != 200 and code != 201 and code != 204:
        var e = newException(GithubError, "Request to github has errored")
        e.code = code
        e.body = parseJson(response.body)
        raise e
    return response.body

proc get_release_by_tag_name*(g: Github, tag: string): JsonNode =
    let url = fmt"/releases/tags/{tag}"
    return parseJson(g.request(url))

proc getLogs*(pretty: bool = true): string =
    var tag1 = execProcess("git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1)").strip()
    var tag2 = execProcess("git tag -l --points-at HEAD").strip()
    let log = execProcess(&"git log {tag1}..{tag2} --pretty=short --oneline --decorate  --format=\"%C(auto) %h %s\"").strip()
    return log

proc formatLogs*(log: string): string =

    var lines : seq[string] = @[]
    for line in splitLines(log, keep_eol = true):
        lines.add(line.strip())
        lines.add("\n")

    var httpUrl = execProcess("git config --get remote.origin.url").strip()
    httpUrl = httpUrl.replace(":", "/")
    httpUrl = httpUrl.replace("git@", "https://")
    if httpUrl[^4..^1] == ".git":
        httpUrl = httpUrl[0..^5]
    echo httpUrl

    var log = join(lines).strip()

    lines = @[]
    for line in splitLines(log, keep_eol = true):
        var data = line.split()
        let commithash = fmt"[`{data[0]}`]({httpUrl}/commit/{data[0]})"
        let message = join(data[1..^1], " ")
        lines.add(commithash)
        lines.add(" ")
        lines.add(message)
        lines.add("\n")
    log = join(lines).strip()
    return log


