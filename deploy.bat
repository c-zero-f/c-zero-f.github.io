@echo off
chcp 65001 > nul 2>&1  :: 解决中文输出乱码问题（可选）

:: =============================================
:: 对应 Shell 的 set -e：脚本遇到错误立即退出
:: =============================================
setlocal enabledelayedexpansion
:: 开启错误检测，当命令执行失败（返回码非0）时退出
if not "%errorlevel%"=="0" exit /b 1

:: =============================================
:: 接收 commit message 参数（对应 Shell 的 MSG="$1"）
:: =============================================
set "MSG=%~1"
:: 判断参数是否为空（对应 Shell 的 [ -z "$MSG" ]）
if not defined MSG (
    echo Commit message is required
    exit /b 1
)

:: =============================================
:: 构建网站（与 Shell 一致）
:: =============================================
echo Building site...
hugo
:: 检查 hugo 命令是否执行成功
if errorlevel 1 (
    echo Error: 网站构建失败！
    exit /b 1
)

:: =============================================
:: 进入 public 目录（对应 Shell 的 cd public）
:: =============================================
cd /d public
:: 检查目录切换是否成功
if errorlevel 1 (
    echo Error: 无法进入 public 目录！
    exit /b 1
)

:: =============================================
:: Git 相关操作（与 Shell 逻辑一致，语法适配 Batch）
:: =============================================
:: 添加所有文件到暂存区
git add .
if errorlevel 1 (
    echo Error: git add 执行失败！
    exit /b 1
)

:: 提交变更（对应 Shell 的 git commit -m "$MSG"）
git commit -m "!MSG!"
if errorlevel 1 (
    echo Error: git commit（public 目录）执行失败！
    exit /b 1
)

:: 推送到 GitHub（对应 Shell 的 git push origin main）
echo Pushing to GitHub Pages...
git push origin gh-pages
if errorlevel 1 (
    echo Error: git push（public 目录）执行失败！
    exit /b 1
)

:: =============================================
:: 返回上级目录（对应 Shell 的 cd ..）
:: =============================================
cd /d ..
if errorlevel 1 (
    echo Error: 无法返回上级目录！
    exit /b 1
)

:: =============================================
:: 提交源代码变更（与 Shell 逻辑一致）
:: =============================================
git add .
if errorlevel 1 (
    echo Error: git add（源代码目录）执行失败！
    exit /b 1
)

git commit -m "!MSG!"
if errorlevel 1 (
    echo Error: git commit（源代码目录）执行失败！
    exit /b 1
)

git push origin main
if errorlevel 1 (
    echo Error: git push（源代码目录）执行失败！
    exit /b 1
)

echo Done!
endlocal
exit /b 0