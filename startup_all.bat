@echo off
REM
REM Copyright@2017 Huawei Technologies Co., Ltd. 
REM

REM read system
if not "%ak%" == "" goto microservice
if not "%sk%" == "" goto microservice

if not exist "credentials" goto nocredentials

REM read user credentials
for /f "tokens=1,2 delims==" %%i in (credentials) do (
  set %%i=%%j
)

REM prepare cse microservice.yaml
REM cse:
REM  credentials:
REM    accessKey: UZLI6CLENEO6D2ANV35U
REM    secretKey: nAQ7jQyynhuDckGGtzNYMJGDZoFqaEfNwhadIXXP
REM    akskCustomCipher: default
:microservice
echo cse:> microservice.yaml
echo   credentials:>> microservice.yaml
echo     accessKey: %ak%>> microservice.yaml
echo     secretKey: %sk%>> microservice.yaml
echo     akskCustomCipher: default>> microservice.yaml

REM read httpproxy properties
if not exist "httpproxy.properties" goto nohttpproxy
for /f "tokens=1,2 delims==" %%i in (httpproxy.properties) do (
  set %%i=%%j
)

if not "%proxy.enabled%" == "true" goto nohttpproxy
if "%proxy.host%" == "" goto httpproxyerror
if "%proxy.port%" == "" goto httpproxyerror

if not exist ".\weather\conf\" md .\weather\conf\
copy httpproxy.properties .\weather\conf\

if not exist ".\weather-beta\conf\" md .\weather-beta\conf\
copy httpproxy.properties .\weather-beta\conf\

if not exist ".\forecast\conf\" md .\forecast\conf\
copy httpproxy.properties .\forecast\conf\

REM  proxy:
REM    enable: true
REM    host: proxy.huawei.com
REM    port: 8080
REM    username: l00247303
REM    passwd: Huawei012.

echo   proxy:>> microservice.yaml
echo     enable: %proxy.enabled%>> microservice.yaml
echo     host: %proxy.host%>> microservice.yaml
echo     port: %proxy.port%>> microservice.yaml
echo     username: %proxy.user%>> microservice.yaml
echo     passwd: %proxy.password%>> microservice.yaml

goto microservice_copy

:nohttpproxy
if exist ".\weather\conf\httpproxy.properties" del .\weather\conf\httpproxy.properties
if exist ".\weather-beta\conf\httpproxy.properties" del .\weather-beta\conf\httpproxy.properties
if exist ".\forecast\conf\httpproxy.properties" del .\forecast\conf\httpproxy.properties

:microservice_copy
copy microservice.yaml .\weather\
copy microservice.yaml .\weather-beta\
copy microservice.yaml .\forecast\
copy microservice.yaml .\fusionweather\
del microservice.yaml

REM mklink with all service
if not exist "weather\lib" mklink /J weather\lib lib
if not exist "weather-beta\lib" mklink /J weather-beta\lib lib
if not exist "forecast\lib" mklink /J forecast\lib lib
if not exist "fusionweather\lib" mklink /J fusionweather\lib lib

REM start all service
echo "start weather"
start weather\startup.bat

echo "start weather-beta"
start weather-beta\startup.bat

echo "start forecast"
start forecast\startup.bat

echo "start fusionweather"
start fusionweather\startup.bat

echo "start weathermapweb"
start weathermapweb\startup.bat

goto end

:httpproxyerror
echo "httpproxy config error."
goto end

:nocredentials
echo "Cannot find ak/sk in credentials file or system environment variables."

:end