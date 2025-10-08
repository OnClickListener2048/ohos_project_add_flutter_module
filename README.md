# 鸿蒙(HarmonyOS)集成 Flutter 模块并使用 FlutterBoost

## 项目简介

本项目旨在演示如何将一个 Flutter 模块以混合开发的形式集成到一个鸿蒙原生工程中。项目中采用业界主流的 **FlutterBoost** 作为路由框架，以实现原生与 Flutter 页面之间统一、流畅的导航体验。

此集成方案的核心亮点是利用**符号链接（软链接）**技术，授权 Flutter 的构建系统直接管理鸿蒙宿主工程的三方库依赖。这种创新的工作流极大地简化了混合开发中的依赖配置，提升了开发效率。

## 核心理念与技术特性

*   **混合开发模式**: 结合鸿蒙原生壳工程的系统能力与 Flutter UI 模块的跨端渲染能力。
*   **鸿蒙版 Flutter**: 采用官方 Flutter SDK 中支持鸿蒙（OpenHarmony）构建目标的版本。
*   **统一路由框架**: 引入 FlutterBoost，为鸿蒙与 Flutter 页面提供统一的路由管理和生命周期控制。
*   **依赖自动化管理**: 通过符号链接，`flutter build har` 构建命令可以自动扫描 Flutter 依赖，并将对应的鸿蒙端原生依赖写入宿主工程的 `oh-package.json5` 文件中，开发者无需手动配置。

## 环境准备

在开始之前，请确保你的开发环境满足以下要求：

1.  **DevEco Studio**: 已安装最新版本，并完成 HarmonyOS SDK 的下载。
2.  **Flutter SDK**: 已安装支持鸿蒙的版本（建议使用 `master` 分支），可通过 `flutter doctor -v` 命令检查 `OpenHarmony toolchain` 是否正常。
3.  **Node.js & ohpm**: `ohpm` 是鸿蒙的包管理器，通常随 DevEco Studio 一同安装。

## 详细集成步骤

### 第一步：创建工程

1.  **创建鸿蒙工程**:
    *   在 DevEco Studio 中，通过 `File > New > New Project` 创建一个新的 “Empty Ability” 工程。
    *   **重要提示**: 请为工程指定一个唯一的包名（例如 `com.example.myharmonyapp`），**绝对不要**使用 `@ohos/flutter_ohos`，否则会在依赖安装时引发包名冲突。

2.  **创建 Flutter 模块**:
    *   在你的工作区，使用命令行创建一个标准的 Flutter 模块。
    ```bash
    flutter create --template module my_flutter_module
    ```

### 第二步：关键操作 - 创建符号链接

这是整个流程中最巧妙且最关键的一步。我们将在 Flutter 模块的根目录下创建一个名为 `.ohos` 的符号链接，并让它指向我们的鸿蒙工程。这会使 Flutter 构建系统“认为”鸿蒙工程是其构建目标的一部分，从而在构建时主动为其管理鸿蒙端的依赖。

**⚠️ 注意**: 在 Windows 系统上创建符号链接，你必须以**管理员身份**运行终端（PowerShell 或 CMD）。

*   **在 Windows (使用 PowerShell):**
    ```powershell
    # 1. 首先 cd 进入你的 flutter 模块目录
    cd path\to\my_flutter_module
    
    # 2. 创建链接，将 <...> 替换为你的鸿蒙工程的完整路径
    New-Item -ItemType SymbolicLink -Path .\.ohos -Target "<你的鸿蒙工程的完整路径>"
    ```

*   **在 macOS / Linux (使用 Terminal):**
    ```bash
    # 1. 首先 cd 进入你的 flutter 模块目录
    cd path/to/my_flutter_module
    
    # 2. 创建链接，将 <...> 替换为你的鸿蒙工程的完整路径
    ln -s "<你的鸿蒙工程的完整路径>" .ohos
    ```

操作完成后，你的 Flutter 模块目录下会多出一个 `.ohos` 文件夹图标，它实际上是一个指向你鸿蒙工程的快捷方式。

### 第三步：在 Flutter 中添加依赖

1.  打开 Flutter 模块中的 `pubspec.yaml` 文件，像平常一样添加 `flutter_boost` 依赖。

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      # 添加 flutter_boost
      flutter_boost: ^5.2.0 # 请使用合适的版本
    ```

2.  在 Flutter 模块目录下运行 `flutter pub get` 来拉取 Dart 依赖。

### 第四步：构建 Flutter 模块为 `.har` 文件

现在，当你构建 Flutter 模块时，构建系统会检测到 `.ohos` 这个链接，并自动将 `flutter_boost` 所需的鸿蒙端依赖配置写入到符号链接指向的鸿蒙工程的 `oh-package.json5` 文件中。

```bash
# 在你的 flutter 模块根目录下执行
flutter build har
```

构建成功后，你会在 Flutter 模块的 `build/ohos/outputs/har/flutter_module.har` 路径下找到编译好的库文件。

### 第五步：在鸿蒙工程中集成 `.har`

1.  在鸿蒙工程的根目录下创建一个名为 `har` 的文件夹。
2.  将上一步生成的 `flutter_module.har` 文件复制到这个 `har` 文件夹中。
3.  打开鸿蒙工程的 `oh-package.json5` 文件，你会发现 `flutter_boost` 的依赖已经被自动添加了。现在，你只需要手动添加对 `flutter_module.har` 本身的依赖即可。

    ```json5
    {
      "name": "com.example.myharmonyapp",
      "version": "1.0.0",
      "dependencies": {
        "flutter_boost": "npm:@ohos/flutter_boost@5.2.0", // 这一行是自动生成的！
        // 你只需要手动添加下面这一行
        "@ohos/flutter_ohos": "file:./har/flutter_module.har" 
      }
    }
    ```
4.  回到 DevEco Studio，在鸿蒙工程的终端中运行 `ohpm install` 来同步所有依赖。

## 开发流程：黄金法则（必读）

这是日常开发中必须严格遵守的准则。由于 Flutter 代码被编译成了一个静态的 `.har` 库，你在 Dart 代码中的任何修改都**不会**通过 Flutter 的热重载机制自动反映到正在运行的鸿蒙应用中。

**每次修改 Flutter 代码后，你都必须遵循以下循环来使改动生效：**

1.  在 Flutter 模块中**修改**你的 Dart 代码并保存。
2.  在 Flutter 模块的根目录下，**重新执行构建命令**以生成新的 `.har` 包：
    ```bash
    flutter build har
    ```
3.  回到 DevEco Studio，**重新运行**你的鸿蒙工程。IDE 会自动加载更新后的 `.har` 文件，你就能看到最新的 Flutter 界面了。

**简而言之：改完 Dart，必跑 `flutter build har`，再跑鸿蒙工程。**
