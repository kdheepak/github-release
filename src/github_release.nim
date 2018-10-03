import strutils
import strformat
import httpclient
import json
import mimetypes
import ospaths
import osproc

type
    Github = ref object
        token: string
        owner: string
        repo: string
        hostname: string
    GithubError = object of Exception
        code: int
        body: JsonNode

proc newGithub(token: string, owner: string, repo: string): Github =
    let hostname = getEnv("GITHUB_HOSTNAME", "github")
    return Github(token: token, owner: owner, repo: repo, hostname: hostname)

proc request(g: Github, url: string,
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

proc get_release_by_tag_name(g: Github, tag: string): JsonNode =
    let url = fmt"/releases/tags/{tag}"
    return parseJson(g.request(url))

proc remove(token: string, owner: string, repo: string, tag: string): int =
    try:
        var g = newGithub(token, owner, repo)
        let release_id = g.get_release_by_tag_name(tag)["id"].getInt()
        var url = fmt"/releases/{release_id}"
        discard g.request(url, "delete")
        echo "Success!"
        return 0
    except GithubError as e:
        echo fmt"[Error] Unable to find/delete tag {tag}: " & e.body["message"].getStr()
        return -1
    except:
        raise

proc getLogs(pretty: bool = true): string =
    var tag1 = execProcess("git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1)").strip()
    var tag2 = execProcess("git tag -l --points-at HEAD").strip()
    let log = execProcess(&"git log {tag1}..{tag2} --pretty=short --oneline --graph --decorate  --format=\"%C(auto) %h %s\"").strip()
    return log

proc create(token: string, owner: string, repo: string, tag: string, target_commit: string = "master", name: string = "", body: string = "", draft: bool = false, prerelease: bool = false): int =
    try:
        if body == "":
            let log = getLogs(true)
            var body = """
            # Changelog

            {log}
            """
        var g = newGithub(token, owner, repo)
        var body = %*{
            "tag_name": tag,
            "target_commitish": target_commit,
            "name": (if name == "": tag else: name),
            "body": body,
            "draft": draft,
            "prerelease": prerelease
        }
        let url = "/releases"
        discard g.request(url, httpMethod = "post", body = $body)
        echo "Success!"
        return 0
    except GithubError as e:
        # let err = cast[GithubError](e)
        # echo "Got exception ", repr(err), " with message ", msg
        if e.body["errors"][0]["code"].getStr() == "already_exists":
            echo fmt"[Error] Unable to create tag {tag}, it already exists."
        else:
            echo fmt"[Error] Unable to create tag {tag}"
            echo e.body
        return -1
    except:
        raise

proc upload(token: string, owner: string, repo: string, file: string, tag: string): int =
    try:
        var g = newGithub(token, owner, repo)
        let release = g.get_release_by_tag_name(tag)
        let release_id = release["id"].getInt()
        var upload_url = release["upload_url"].getStr()
        upload_url = upload_url.replace("{?name,label}", "").strip(chars={'"'})
        let file_name = fmt"{file.splitFile.name}{file.splitFile.ext}"
        var url = fmt"{upload_url}?name={file_name}"
        var headers= {
            "Content-Type": "application/zip",
            "name": file_name,
            "label": file_name,
        }.newHttpHeaders
        var mimes = newMimetypes()
        var body = file.readFile
        discard g.request(url, httpMethod = "post", body = $body, headers = headers)
        echo "Success!"
    except GithubError as e:
        echo fmt"[Error] Unable to upload {file} to {tag}. Ensure that the tag already exists and the asset doesn't"
        return -1
    except:
        raise

proc logs(pretty: bool = true): int =
    let log = getLogs(pretty)
    echo log
    return 0


when isMainModule:

    import cligen
    import os
    const version_string = staticExec("git rev-parse --verify HEAD --short")

    dispatchMulti(
        [ upload ],
        [ create ],
        [ remove ],
        [ logs ],
        # version = ("version", "github-release (v0.1.0-alpha " & version_string & ")")
    )
