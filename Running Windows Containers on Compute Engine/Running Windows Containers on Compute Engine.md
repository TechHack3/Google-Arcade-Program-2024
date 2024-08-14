# Running Windows Containers on Compute Engine 

### Run the following Commands in Command Prompt

```
docker images
mkdir my-windows-app
cd my-windows-app
mkdir content
call > content\index.html
notepad content\index.html
```
```
<html>
  <head>
    <title>Windows containers</title>
  </head>
  <body>
    <p>Windows containers are cool!</p>
  </body>
</html>
```
```
call > Dockerfile
notepad Dockerfile
```
```
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

WORKDIR /inetpub/wwwroot

COPY content/ .
```
```
docker build -t gcr.io/dotnet-atamel/iis-site-windows .
docker images
```

