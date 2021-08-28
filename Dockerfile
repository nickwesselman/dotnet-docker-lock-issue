# escape=`

FROM mcr.microsoft.com/dotnet/sdk:5.0-windowsservercore-ltsc2019 as debug

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN $ErrorActionPreference = 'Stop'; `
    $url = 'https://download.sysinternals.com/files/SysinternalsSuite-Nano.zip'; `
    Invoke-WebRequest $url -OutFile suite.zip; `
    Expand-Archive suite.zip 'c:\sysinternals-nano'; `
    rm suite.zip; `
    $path = ${Env:PATH} + ';c:\sysinternals-nano;'; `
    setx /M PATH $path

WORKDIR C:\src
ENTRYPOINT ["dotnet", "watch", "-v", "run", "--no-launch-profile", "--verbose"]