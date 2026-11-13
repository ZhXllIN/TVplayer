# TVplayer · 双屏广告播放台

[English](README.en.md)

TVplayer 在一台 64 位 Windows 10/11 电脑上管理两台电视。A、B 通道可以显示不同内容，分别设置播放列表、播放时段和登录自启。

## 快速开始

1. 从 [Releases](https://github.com/ZhXllIN/TVplayer/releases/latest) 下载离线 ZIP，完整解压到一个可写的固定目录。包内含 LibreOffice、Poppler 和 libmpv，播放电脑无需安装 Office 或另配解码器。
2. 接好电视，按 **Win + P → 扩展**。双击 **Start.cmd**，分别打开 A、B 通道。
3. 在各通道添加素材、选择目标显示器，点击 **保存设置并开始 / 等待定时播放**。

## 用 Git 克隆和更新

先安装 Git 和 Git LFS，在 PowerShell 中运行以下命令。两个较大的 DLL 通过 Git LFS 下载。公开仓库支持匿名克隆。

**首次克隆并启动**

~~~powershell
git lfs install
git clone https://github.com/ZhXllIN/TVplayer.git
cd TVplayer
git lfs pull
.\Start.cmd
~~~

**更新已有副本**

关闭播放器，在已有的 `TVplayer` 文件夹内打开 PowerShell，再运行以下命令。本地播放配置与素材保存在 Git 忽略的 `PlayerData` 目录。

~~~powershell
git lfs install
git pull --ff-only
git lfs pull
.\Start.cmd
~~~

## 素材与播放

| 类型 | 支持的文件 | 播放方式 |
| --- | --- | --- |
| 视频 | MP4、MKV、MOV、AVI、WMV、M4V、WebM、TS、MPG、MPEG | 播完切换到下一项 |
| 图片 | PNG、JPG、JPEG、BMP | 默认停留 20 秒，可调整 |
| 演示文稿与文档 | PPT、PPTX、PDF | 导入时转成静态页面，按图片时长播放；PPT 动画和嵌入视频不保留 |

### v1.1.0 文档导入与列表操作

- **导入**：选择 PDF、PPT 或 PPTX 后，播放器在后台逐份转换，页面缓存为长边 1920 像素的高质量 JPEG。每份文档在列表中占一行，多页文档显示页数；旧列表中属于同一份文档的页面会自动归组。
- **从指定页播放**：选中文档，填写“起播页”，点击“保存设置并开始 / 等待定时播放”。例如，输入 3 会从第 3 页开始顺序播放；同时勾选“单项播放”则固定显示第 3 页。
- **批量移除**：在列表中用 Ctrl + 单击多选、Shift + 单击连选、Ctrl + A 全选，再点击“移除选中文件”。移除文档会一并移除其所有播放页，原始文件保留。

默认循环整个列表。勾选“单项播放”可固定一页或循环当前视频。两路声音使用系统默认输出，界面暂未提供独立音频设备选择。

## 定时与恢复

播放时段填入 `08:00-22:00`、休息时段填入 `12:00-13:00`，即可在午间暂停。支持跨午夜；播放时段留空表示全天，休息留空表示不休息。勾选登录后自动启动并保存，下次 Windows 登录会恢复该通道。休息时输出窗口隐藏，电视可能显示桌面。

## 源码与迁移

源码包含启动器、控制台、播放器脚本及视频桥接代码。源码仓库包含完整运行目录。已保存的配置、导入的媒体及转换页面位于 `PlayerData`。迁移已配置的播放台时复制整个目录，在新电脑重新选择显示器并保存自启设置。

## 离线包中的第三方组件

| 组件 | 包内位置 | 用途与来源 |
| --- | --- | --- |
| LibreOffice 26.2.7（Impress） | `tools/LibreOffice/` | 将 PPT、PPTX 转为 PDF。采用 The Document Foundation 的 Windows x64 构建，随包声明见该目录中的 `LICENSE.html`、`license.txt` 和 `NOTICE`。[LibreOffice 项目](https://www.libreoffice.org/) |
| Poppler 26.07.0 | `tools/poppler/` | 使用 `bin/pdftoppm.exe` 和随附 DLL 将 PDF 渲染为 JPEG，包含配置和字体资源目录。[Poppler 项目](https://poppler.freedesktop.org/) |
| mpv（libmpv） | `tools/mpv/libmpv-2.dll` | 通过 `PortableVideo.cs` 解码并播放视频。此 DLL 取自 Tsukimi 26.6.1 的 Windows 分发包；26.6.1 是 Tsukimi 的版本。[mpv 项目](https://mpv.io/) · [Tsukimi 项目](https://github.com/tsukinaha/tsukimi) |
