+++
title = "搭建Hugo网站"
subtitle = ""
date = 2025-12-29T16:02:45-04:00
lastmod = 2025-12-29T16:02:45-04:00
author = "zachary"

draft = false
tags = []
categories = []
description = ""
+++

## hugo 安装

- 为配套使用 LoveIt 主题，需要安装 Hugo 的版本号为 0.145.0
- 可以从github 下载 hugo_extended_withdeploy_0.145.0_windows-amd64.zip 包
- 解压到任意目录，例如 `C:\hugo`
- 将 `C:\hugo` 添加到系统环境变量 `PATH` 中

## 初始化博客

```bash
# 初始化博客
hugo new site my-site

# 进入 博客目录
cd my-site

# 初始化 git
git init
```

### 添加主题

```bash
# 使用 Git 子模块 功能 添加 LoveIt 主题
git submodule add https://github.com/dillonzq/LoveIt.git themes/LoveIt

# 进入 LoveIt 主题目录
cd themes/LoveIt

# 拉取所有标签
git fetch origin --tags

# 创建一个新的分支 theme-fixed-v0.3.0 并切换到该分支
git checkout -b theme-fixed-v0.3.0 v0.3.0

# 返回到博客根目录
cd ../../

# 查看当前状态，确认是否有可添加项目
git status

# 添加 .gitmodules 文件和 themes/LoveIt 目录到 Git 暂存区
git add .gitmodules themes/LoveIt

# 提交更改
git commit -m "安装LoveIt主题，并固化主题版本为v0.3.0"
```

- 确认主题是否已经使用了 v0.3.0 版本
  
```bash
# 切换到主题目录
cd themes/LoveIt

# 确认当前版本
git describe --tags

# 屏幕打印出 v0.3.0 代表 LoveIt 主题已切换到 v0.3.0 版本
```

### 配置 hugo.toml 文件

- 可以参考 [LoveIt 主题文档](https://hugoloveit.com/zh-cn/theme-documentation-basics/#basic-configuration) 进行配置, 主要查看 2.3 基础配置 章节信息。