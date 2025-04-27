# Cf. https://hub.docker.com/_/microsoft-windows-servercore
FROM mcr.microsoft.com/windows/servercore:1809-KB5059091-amd64@sha256:c2aaf8f2dc50fe2085a123945e8b7908b89e3c05cba572f33c9550b5418f29ed AS builder
SHELL ["cmd", "/S", "/C"]

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-04-27"
LABEL author="Florian Stosse"
LABEL description="Windows 10 LTSC 2019 image, with Microsoft Build Tools 2019 (v16.0)"
LABEL license="MIT license"

# Set up environment to collect install errors.
ADD https://aka.ms/vscollect.exe C:/TEMP/collect.exe
ADD Install.cmd C:/TEMP

# Download channel for fixed install.
ADD https://aka.ms/vs/16/release/channel C:/TEMP/VisualStudio.chman

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:/TEMP/vs_buildtools.exe

RUN \
  C:/TEMP/Install.cmd C:/TEMP/vs_buildtools.exe --quiet --wait --norestart --nocache \
  --channelUri C:/TEMP/VisualStudio.chman \
  --installChannelUri C:/TEMP/VisualStudio.chman \
  --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended \
  --add Microsoft.VisualStudio.Component.VC.Llvm.Clang \
  --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset \
  --add Microsoft.VisualStudio.Component.VC.ATLMFC \
  --add Microsoft.VisualStudio.Component.VC.CLI.Support \
  --installPath C:/BuildTools

FROM mcr.microsoft.com/windows/servercore:1809-KB5059091-amd64@sha256:c2aaf8f2dc50fe2085a123945e8b7908b89e3c05cba572f33c9550b5418f29ed

COPY --from=builder C:/BuildTools/ C:/BuildTools

# Use developer command prompt and start PowerShell if no other command specified.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
