# Windows Docker Hyper-V File Lock Issue

## Reproducing

1. `docker-compose build`
1. `docker-compose up -d`
1. Open http://localhost:8090/ and confirm the ASP.NET Core app is running.
1. Monitor app build via `docker-compose logs -f dotnet-docker-lock-issue`
1. Make a change to a file in the app (e.g. add/remove whitespace from `Startup.cs`)

### Expected
`dotnet watch` kills the running app, rebuilds, and runs the app again

### Actual
`dotnet watch` is able to kill the app, but the build fails with one of two errors:

> CSC : error CS2012: Cannot open 'C:\src\obj\container\Debug\net5.0\dotnet-docker-lock-issue.dll' for writing -- 'The process cannot access the file 'C:\src\obj\container\Debug\net5.0\dotnet-docker-lock-issue.dll' because it is being used by another process.' [C:\src\dotnet-docker-lock-issue.csproj]


> C:\Program Files\dotnet\sdk\5.0.202\Microsoft.Common.CurrentVersion.targets(4919,5): warning MSB3026: Could not copy "C:\src\obj\container\Debug\net5.0\apphost.exe" to "C:\src/bin/container/Debug\net5.0\dotnet-docker-lock-issue.exe". Beginning retry 1 in 1000ms. The process cannot access the file 'C:\src\bin\container\Debug\net5.0\dotnet-docker-lock-issue.exe' because it is being used by another process.  [C:\src\dotnet-docker-lock-issue.csproj]

### Observed file locks

Following the failed build, neither the `bin\` nor `obj\` folders appear to have any open handles on the container itself. However the container host seems to be holding them in the Hyper-V VM process.

#### On the container

```
PS C:\> handle64 -accepteula C:\src\obj\

Nthandle v4.22 - Handle viewer
Copyright (C) 1997-2019 Mark Russinovich
Sysinternals - www.sysinternals.com

No matching handles found.

PS C:\> handle64 -accepteula C:\src\bin\

Nthandle v4.22 - Handle viewer
Copyright (C) 1997-2019 Mark Russinovich
Sysinternals - www.sysinternals.com

No matching handles found.
```

#### On the host

```
PS C:\> handle64.exe C:\dev\dotnet-docker-lock-issue\obj\

Nthandle v4.22 - Handle viewer
Copyright (C) 1997-2019 Mark Russinovich
Sysinternals - www.sysinternals.com

vmwp.exe           pid: 17640  type: File          35DC: C:\dev\dotnet-docker-lock-issue\obj\container\Debug\net5.0\d377a3cb-bad4-4c2d-8e66-e6a46db6ba2c_dotnet-docker-lock-issue.dll

PS C:\> handle64.exe C:\dev\dotnet-docker-lock-issue\bin

Nthandle v4.22 - Handle viewer
Copyright (C) 1997-2019 Mark Russinovich
Sysinternals - www.sysinternals.com

vmwp.exe           pid: 17640  type: File          3520: C:\dev\dotnet-docker-lock-issue\bin\container\Debug\net5.0\dotnet-docker-lock-issue.exe
vmwp.exe           pid: 17640  type: File          3524: C:\dev\dotnet-docker-lock-issue\bin\container\Debug\net5.0\dotnet-docker-lock-issue.dll
vmwp.exe           pid: 17640  type: File          3568: C:\dev\dotnet-docker-lock-issue\bin\container\Debug\net5.0\dotnet-docker-lock-issue.Views.dll
```
