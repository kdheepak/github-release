import strutils
import strformat
import httpclient
import json
import mimetypes
import ospaths
import osproc

import ./github

proc remove*(token: string, owner: string, repo: string, tag: string): int =
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


proc create*(token: string, owner: string, repo: string, tag: string, target_commit: string = "master", name: string = "", body: string = "", draft: bool = false, prerelease: bool = false): int =
    try:
        var body_string: string = ""
        if body == "":
            let log = getLogs(true).formatLogs
            body_string = &"""
            # Changelog

            {log}
            """
            var tmp_body = ""
            for line in splitLines(body_string, keep_eol = true):
                tmp_body.add(line.strip())
                tmp_body.add("\n")
            body_string = join(tmp_body)
        else:
            body_string = body
        var g = newGithub(token, owner, repo)
        var body = %*{
            "tag_name": tag,
            "target_commitish": target_commit,
            "name": (if name == "": tag else: name),
            "body": body_string,
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

proc upload*(token: string, owner: string, repo: string, file: string, tag: string): int =
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

proc logs*(pretty: bool = true): int =
    let log = getLogs(pretty)
    echo log
    return 0

proc version*(pretty: bool = true): int =
    const version_string = staticExec("git describe --tags HEAD")
    echo version_string
    return 0

