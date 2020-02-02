import os, sequtils, strutils

type
  Photo = object
    id: int
    title: string
    filename: string
    ext: string
    size: int
    width: int
    height: int

let
  photoUrl = "https://localhost/photos/"
  thumbUrl = "https://localhost/photos/thumbs/"
  templatePath = getCurrentDir() & "/template/"
  exportFilename = "index.html"
  headerFilename = "header.html"
  footerFilename = "footer.html"

proc imageext(p: Photo): string = addFileExt(p.filename, p.ext)
proc fullimageurl(p: Photo): string = photoUrl & p.imageext()
proc fullthumburl(p: Photo): string = thumbUrl & p.imageext()
proc widthxheight(p: Photo): string = $p.width & "x" & $p.height

proc renderItem(p: Photo): string =
  # anchor tag
  result = "<a href=\""
  result.add p.fullimageurl()
  result.add "\" data-size=\""
  result.add p.widthxheight()
  result.add "\">"
  # img tag
  result.add "<img src=\""
  result.add p.fullthumburl()
  result.add "\">"
  # close anchor
  result.add "</a>"

proc compilePhotos(photopath: string): seq[Photo] =
  for kind, path in walkDir(photopath):
    if not path.existsFile: continue
    let (_, name, ext) = splitFile(path)
    result.add Photo(
      filename: name,
      ext: ext,
      size: int(path.getFileSize)
    )

# main
let args = commandLineParams()
if args.len <= 0:
  echo "missing photo path"
  quit(-1)

let originalPhotosPath = args[0]

if not originalPhotosPath.existsDir:
  echo "photo path does not exist"
  quit(-2)

var templates: seq[string]
let headerFile = templatePath & headerFilename
if headerFile.existsFile:
  templates.add headerFile.readFile

templates.add compilePhotos(originalPhotosPath).map(renderItem).foldl(a & b)

let footerFile = templatePath & footerFilename
if footerFile.existsFile:
  templates.add footerFile.readFile

let exportFile =
  if args.len > 1: args[1] & exportFilename
  else: getCurrentDir() & "/" & exportFilename

exportFile.writeFile(templates.join)
if exportFile.existsFile:
  echo "success: compiled ", exportFile
else:
  echo "failed"
  quit(-3)
