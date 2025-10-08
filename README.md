# 鸿蒙与 Flutter 源码依赖混合开发指南 (支持热重载)

![运行本项目您将得到](img.png)

## 项目简介

本文档旨在详细介绍一种先进的鸿蒙（HarmonyOS）与 Flutter 混合开发模式：**源码依赖集成**。

不同于传统的将 Flutter 打包成 `.har` 静态库的模式，本方案通过**符号链接（软链接）**技术，将鸿蒙主工程直接关联到 Flutter 模块中。这种方式的最大优势在于，它打通了 Flutter 工具链与鸿蒙工程的直接交互，从而实现了在开发 Flutter UI 时的**热重载（Hot Reload）**功能，极大地提升了开发效率和体验。

## 核心优势

-   **支持热重载**: 修改 Dart 代码后可立即在鸿蒙应用中看到效果，无需重新编译整个鸿蒙工程。
-   **源码级联动**: Flutter 与鸿蒙工程在源码层面直接关联，便于调试和管理。
-   **自动化配置**: 利用 `flutter run` 命令，可以自动为鸿蒙宿主工程配置模块依赖和编译产物。

## 最终项目结构

在开始之前，请先规划好你的项目目录，推荐的结构如下：

```
ohos_flutter_module_demo/       # 项目根目录
├── my_flutter_module/          # Flutter 模块
│   ├── .ohos -> ../ohos_app    #【核心】指向鸿蒙主工程的符号链接
│   ├── lib/
│   └── pubspec.yaml
└── ohos_app/                   # 鸿蒙主工程
    ├── entry/
    ├── flutter_module/         #【关键】从 Flutter 模块复制而来的模块源码
    └── oh-package.json5
```

## 操作步骤

### 第一步：创建工作目录和项目

1.  **创建根目录**
    创建一个统一的工作目录，用于存放后续的 Flutter 和鸿蒙项目。
    ```bash
    mkdir ohos_flutter_module_demo
    cd ohos_flutter_module_demo
    ```

2.  **创建 Flutter 模块**
    在根目录下，创建一个标准的 Flutter 模块。
    ```bash
    flutter create --template=module my_flutter_module
    ```
    > **提示**: 如果你使用 `fvm` 管理 Flutter 版本，请先确保已切换到支持鸿蒙的 SDK 版本（如 `fvm use <harmony_version>`），然后使用 `fvm flutter ...` 执行命令。

3.  **创建鸿蒙工程**
    使用 DevEco Studio，在根目录 (`ohos_flutter_module_demo`) 下创建一个新的鸿蒙工程，并将其命名为 `ohos_app`。
    -   确保工程的保存路径为 `..../ohos_flutter_module_demo/ohos_app`。
    -   工程创建后，建议立即在 DevEco Studio 中配置好调试签名 (`File -> Project Structure -> Signing Configs`)。

### 第二步：配置源码依赖 (核心步骤)

这是实现源码联动的关键。我们将通过符号链接，将 Flutter 模块默认的 `.ohos` 宿主工程替换为我们自己的 `ohos_app` 工程。

1.  **复制 `flutter_module` 源码**
    这是为了防止后续步骤出现 `Can not found module.json5` 的错误。将 Flutter 模块自动生成的 `.ohos` 目录下的 `flutter_module` 文件夹，完整地复制到我们的鸿蒙主工程 `ohos_app` 的根目录下。

    ```bash
    # 在 ohos_flutter_module_demo 根目录下执行
    cp -r my_flutter_module/.ohos/flutter_module ohos_app/
    ```

2.  **创建符号链接**
    进入 Flutter 模块目录，删除其自动生成的 `.ohos` 文件夹，然后创建一个新的同名符号链接，使其指向我们的 `ohos_app` 工程。

    **⚠️ 注意**: 在 Windows 上创建符号链接通常需要**管理员权限**。

    *   **在 macOS / Linux 上:**
        ```bash
        cd my_flutter_module
        rm -rf .ohos
        ln -s ../ohos_app .ohos
        ```

    *   **在 Windows (使用 PowerShell 管理员模式):**
        ```powershell
        cd my_flutter_module
        Remove-Item .ohos -Recurse -Force
        New-Item -ItemType SymbolicLink -Path .\.ohos -Target ..\ohos_app
        ```

    完成此步骤后，Flutter 的构建工具链就会将 `ohos_app` 识别为其鸿蒙端的宿主工程。

### 第三步：运行 Flutter 以自动配置工程

现在，让我们运行 `flutter run` 命令。这个命令会触发 Flutter 工具链，它将自动检查并配置链接好的 `ohos_app` 工程。

```bash
# 确保你当前在 my_flutter_module 目录下
flutter run
```

在命令执行期间，Flutter 会完成以下重要工作：
1.  **编译 Flutter 引擎**: 生成 `flutter.har` 并放置在 `ohos_app/har/` 目录下。
2.  **更新构建配置**: 向 `ohos_app/build-profile.json5` 文件中自动添加 `flutter_module` 模块的引用。

    你可以检查 `ohos_app/build-profile.json5` 文件，会发现新增了如下内容：
    ```diff
      "modules": [
        ...
    +    {
    +      "name": "flutter_module",
    +      "srcPath": "./flutter_module"
    +    }
      ]
    ```

3.  **构建并安装 HAP**: 最终，它会调用鸿蒙的构建工具链（Hvigor）来编译整个 `ohos_app` 工程，并将其安装到连接的设备或模拟器上。

    你会看到类似以下的控制台输出：
    ```
    Running Hvigor task assembleHap...
    ✓ Built ../ohos_app/entry/build/default/outputs/default/entry-default-signed.hap.
    installing hap. bundleName: com.example.ohos_app
    ```

### 第四步：验证与后续开发

`flutter run` 成功后，你的鸿蒙应用将会启动，此时它可能只显示一个鸿蒙原生页面。但这已经证明了整个源码依赖的链路已经打通。

**开发流程与热重载：**
-   保持 `flutter run` 进程不退出。
-   现在，你可以去修改 `my_flutter_module/lib/` 下的任何 Dart 代码。
-   保存代码后，在终端中按下 `r` 键即可触发**热重载 (Hot Reload)**，或按下 `R` 键触发**热重启 (Hot Restart)**。你的修改会几乎瞬间反映在运行的鸿蒙应用中。

## 后续步骤

本指南主要解决了项目搭建和开发流程的问题。接下来，你需要在 `ohos_app` 工程中编写原生代码，来创建和管理 Flutter 引擎实例，并将其加载到合适的页面容器中，从而真正地把 Flutter UI 显示出来。

---