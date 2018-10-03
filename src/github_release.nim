import strutils
import strformat
import httpclient
import json
import mimetypes
import ospaths

type
    Github = ref object
        token: string
        owner: string
        repo: string

proc newGithub(token: string, owner: string, repo: string): Github =
    return Github(token: token, owner: owner, repo: repo)

proc request(g: Github, url: string,
              httpMethod: string = "get", body = "",
              headers: HttpHeaders = nil): string =
    var client = newHttpClient()
    client.headers = newHttpHeaders({ "Authorization": fmt"token {g.token}" })
    var realurl: string
    if url.startsWith("/"):
        realurl = fmt"https://api.github.com/repos/{g.owner}/{g.repo}" & url
    else:
        realurl = url
    let response = client.request(realurl, httpMethod = httpMethod, body = body, headers = headers)
    # echo response.status
    # echo response.body
    # echo response.headers
    return response.body

proc get_release_by_tag_name(g: Github, tag: string): string =
    let url = fmt"/releases/tags/{tag}"
    return g.request(url)

proc delete_release(token: string, owner: string, repo: string, tag: string): int =
    var g = newGithub(token, owner, repo)
    let release_id = parseJson(g.get_release_by_tag_name("v0.1.0"))["id"]
    var url = fmt"/releases/{release_id}"
    echo g.request(url, "delete")

proc create(token: string, owner: string, repo: string, tag: string, target_commit: string = "master", name: string = "", body: string = "", draft: bool = false, prerelease: bool = false): int =
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
    echo g.request(url, httpMethod = "post", body = $body)


proc upload(token: string, owner: string, repo: string, file: string, tag: string): int =
    var g = newGithub(token, owner, repo)
    let release = parseJson(g.get_release_by_tag_name(tag))
    let release_id = release["id"]
    var upload_url = $release["upload_url"]
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
    echo url
    echo g.request(url, httpMethod = "post", body = $body, headers = headers)


when isMainModule:

    import cligen
    import os
    const version_string = staticExec("git rev-parse --verify HEAD --short")

    dispatchMulti(
        [ upload ],
        [ create ],
        [ delete_release ],
        # version = ("version", "github-release (v0.1.0-dev " & version_string & ")")
    )
