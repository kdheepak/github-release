when defined(crosswin):
  switch("cc", "gcc")
  const arch =
    if buildCPU == "amd64":
      "x86_64"
    else:
      "i686"
  const mingwExe = arch & "-w64-mingw32-gcc"
  switch("gcc.linkerexe", mingwExe)
  switch("gcc.exe", mingwExe)
  switch("gcc.path", "/usr/bin/")
  switch("gcc.options.linker", "")
  switch("os", "windows")
  switch("define", "windows")
else:
  echo "Not running windows"

