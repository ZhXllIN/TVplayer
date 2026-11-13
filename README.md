# TVplayer · 双屏广告播放台

[English](README.en.md)

TVplayer 在一台 64 位 Windows 10/11 电脑上管理两台电视。A、B 通道可以显示不同内容，分别设置播放列表、播放时段和登录自启。

## 快速开始

1. 从 [Releases](https://github.com/ZhXllIN/TVplayer/releases/latest) 下载离线 ZIP，完整解压到一个可写的固定目录。包内含 LibreOffice、Poppler 和 libmpv，播放电脑无需安装 Office 或另配解码器。
2. 接好电视，按 **Win + P → 扩展**。双击 **Start.cmd**，分别打开 A、B 通道。
3. 在各通道添加素材、选择目标显示器，点击 **保存设置并开始 / 等待定时播放**。

## 素材与播放

| 类型 | 支持的文件 | 播放方式 |
| --- | --- | --- |
| 视频 | MP4、MKV、MOV、AVI、WMV、M4V、WebM、TS、MPG、MPEG | 播完切换到下一项 |
| 图片 | PNG、JPG、JPEG、BMP | 默认停留 20 秒，可调整 |
| 演示文稿与文档 | PPT、PPTX、PDF | 导入时转成静态页面，按图片时长播放；PPT 动画和嵌入视频不保留 |

默认循环整个列表。勾选“单项播放”可固定一页或循环当前视频。两路声音使用系统默认输出，界面暂未提供独立音频设备选择。

## 定时与恢复

播放时段填入 `08:00-22:00`、休息时段填入 `12:00-13:00`，即可在午间暂停。支持跨午夜；播放时段留空表示全天，休息留空表示不休息。勾选登录后自动启动并保存，下次 Windows 登录会恢复该通道。休息时输出窗口隐藏，电视可能显示桌面。

## 源码与迁移

源码包含启动器、控制台、播放器脚本及视频桥接代码。要从源码运行，请将 Release 中的完整 `tools` 目录复制到 `Start.cmd` 同级目录。已保存的配置、导入的媒体及转换页面位于 `PlayerData`。迁移已配置的播放台时复制整个目录，在新电脑重新选择显示器并保存自启设置。

## 离线包中的第三方组件

| 组件 | 包内位置 | 用途与来源 |
| --- | --- | --- |
| LibreOffice 26.2.7（Impress） | `tools/LibreOffice/` | 将 PPT、PPTX 转为 PDF。采用 The Document Foundation 的 Windows x64 构建，随包声明见该目录中的 `LICENSE.html`、`license.txt` 和 `NOTICE`。[LibreOffice 项目](https://www.libreoffice.org/) |
| Poppler 26.07.0 | `tools/poppler/` | 使用 `bin/pdftoppm.exe` 和随附 DLL 将 PDF 渲染为 PNG，包含配置和字体资源目录。[Poppler 项目](https://poppler.freedesktop.org/) |
| mpv（libmpv） | `tools/mpv/libmpv-2.dll` | 通过 `PortableVideo.cs` 解码并播放视频。此 DLL 取自 Tsukimi 26.6.1 的 Windows 分发包；26.6.1 是 Tsukimi 的版本。[mpv 项目](https://mpv.io/) · [Tsukimi 项目](https://github.com/tsukinaha/tsukimi) |

Git 的 `tools/` 目录仅跟踪本项目的 `mpv/PortableVideo.cs` 桥接源码。上表中的运行文件随 Release 离线 ZIP 提供。GitHub 自动生成的 **Source code (zip)** 仅含源码；部署时请下载 **TVplayer-v1.0.0-win-x64-offline.zip**。界面使用 Windows PowerShell、WPF 和 Windows Forms，图片由 WPF 显示。
