# 圣经小助手

帮朋友开发的应用，因为用了 CocoaPods ，请注意打开 `Bible Assistant.xcworkspace` 工程。 

此应用可在 App Store 免费下载：[https://itunes.apple.com/cn/app/sheng-jing-xiao-zhu-shou/id851014654?l=en&mt=8](https://itunes.apple.com/cn/app/sheng-jing-xiao-zhu-shou/id851014654?l=en&mt=8)

## UI 设计

使用 Storyboard，采用 Tabbed Application 模版，分为 5 个部分：

1. 圣经：书签，圣经卷、章的选择，文本阅读；
2. 金句：随机从圣经中选择某一个小节显示；
3. 搜索：对圣经进行全文搜索，高亮关键字；
4. 音频：音频的下载和管理；
5. 设置：音频等偏好，一些信息。

iOS 7 的基本风格，力求简洁（没有专业设计师）。另外，大部分圣经文本显示都支持 iOS 7 的字体大小偏好。

## 逻辑设计

基本就是使用 UICollectionViewController 和 UITableViewController 。

### 跳转

包括从金句、书签、音频跳转至对应的圣经文本，还有非初次打开时跳转至上次阅读处。

主要实现是在对应的 ViewController 里设置 TabBarController 的 selectedViewController

```Objective-C
self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
```

然后用 NSNotification 附带 Location 再深入到圣经阅读界面。

 注意圣经在第 0 个，所以这样写没有问题，如果是在其它 Tab，就要换一种办法。

### 单例

用单例实现 `BADownloadManager` 和 `BAAudioPlayer` ，才好全局“下载”和“播放”。

其中下载的进度和播放的进度都用 `NSNotification` 传递，减小耦合。

### 数据模型

普通代码里主要用 NSDictionary 传递数据，没有特别封装，浏览代码时稍微注意即可。

#### Core Data 模型：

* BibleAudio：保存音频信息，下载的音频数据用 BAAudioSaver 写入 Library/Caches ；
	- 注意使用了 BibleAudio+BAAdditions 扩展，封装一些常用操作。
* Bookmark：保存书签信息。

### 其它

圣经是 XML 格式，且在多处使用，为了减少内存占用，公用 BAAppDelegate 的 ONOXMLDocument *bible 实例。

## 第三方库

* Ono：用于解析 `bible.xml`，提供数据源
* MagicalRecord：更便捷地使用 Core Data
* SGNavigationProgress：在 NavigationBar 上显示音频播放进度
* MBProgressHUD：状态提示
* FFCircularProgressView：用于实现带进度的下载按钮
* Reachability：查看网络的可访问状态
