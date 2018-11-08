---
title: 在 macOS Sierra 10.12.2 上編譯 Caffe 並使用 DIGITS
tags:
permalink: macos-sierra-10-12-2-build-caffe
id: 5acda53481f41f000158dc02
updated: '2017-01-23 00:12:50'
date: 2017-01-08 02:03:14
---

> Update: 目前推薦使用 Docker 環境的 DIGITS

最近在玩 Machine learning，編譯 caffe 跟啟動 DIGITS 的時候遇到一些瓶頸，在這裡記錄下解決方案並分享給需要的人。過程中發生錯誤都可以在下面留言詢問喔！

這邊因為我 training 的量比較少，我就沒有用 GPU，因此這篇不會教怎麼裝 n 卡的驅動程式，不過這邊有[教學](https://gist.github.com/doctorpangloss/f8463bddce2a91b949639522ea1dcbe4#file-install_caffe-sh-L9-L25)，在設定 `Makefile.config` 的時候也記得去掉 `USE_CUDNN := 1` 最前面的 `#`，這樣應該就可以了，其他部分跟本教學通用。

### homebrew install
如果已經安裝過 homebrew 則可以跳過此步驟。
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### dependency install
首先要確認透過 homebrew 安裝的 Python 已經刪除：
```bash
brew uninstall python
```

接著執行：
```bash
brew install -vd snappy leveldb gflags glog szip lmdb
brew install hdf5 opencv
brew upgrade libpng
brew tap homebrew/versions
```

執行 `brew edit opencv`，然後更改下面兩行：
```
-DPYTHON_LIBRARY=#{py_prefix}/lib/libpython2.7.dylib
-DPYTHON_INCLUDE_DIR=#{py_prefix}/include/python2.7
```

編譯並安裝 protobuf 2.6.1：
```
cd ~/Documents
curl -LO https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.bz2
tar xvjf protobuf-2.6.1.tar.bz2
rm protobuf-2.6.1.tar.bz2
cd protobuf-2.6.1
./configure
make
make check
sudo make install
cd python
sudo python2.7 setup.py build
sudo python2.7 setup.py install
```

然後編譯並安裝 boost：
```bash
brew install --build-from-source -vd boost159 boost-python159
```

接下來執行：
```bash
brew link --force boost159
```

### download caffe & prepare deps
```bash
cd ~/Documents
git clone https://github.com/BVLC/caffe.git
cd caffe
git checkout 20feab5771ae5cbb257cfec85e0b98da06269068
cp Makefile.config.example Makefile.config
```

然後我們要換一個 compiler，請登入 https://developer.apple.com/downloads/ ，然後下載 [Xcode Command Line Tools 7.3](http://adcdownload.apple.com/Developer_Tools/Command_Line_Tools_OS_X_10.11_for_Xcode_7.3/Command_Line_Tools_OS_X_10.11_for_Xcode_7.3.dmg)，接著安裝它，然後執行：
```bash
sudo xcode-select --switch /Library/Developer/CommandLineTools
```

### Configure Makefile.config
打開 `Makefile.config`，將 `BLAS_INCLUDE` 那行變更為：
```
BLAS_INCLUDE := /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk/System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/Headers
```

將 `BLAS_LIB` 那行變更為：
```
BLAS_LIB := /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A
```

將 `PYTHON_INCLUDE` 那行變更為：
```
PYTHON_INCLUDE := /usr/include/python2.7 \
     /Library/Python/2.7/site-packages/numpy/core/include
```

將 `PYTHON_LIB` 那行變更為：
```
PYTHON_LIB := /usr/lib
```

`# WITH_PYTHON_LAYER := 1` 變更為：`WITH_PYTHON_LAYER := 1`

`# USE_LEVELDB := 0` 變更為：`USE_LEVELDB := 0`

### build caffe
開始編譯！
```bash
make -j8 all
```

最後裝好一些 python dependency，然後就開始跑測試，測試過程中可能會有很多 Warning，不用理他。
```bash
sudo -H easy_install pip
pip install --user -r python/requirements.txt
sudo -H pip install protobuf
make -j8 pytest
make -j8 test
make -j8 runtest
make -j8 pycaffe
make -j8 pytest
```

測試跑完之後，執行下列指令：
```bash
make -j8 distribute
```

make 好之後，執行以下指令讓你可以在 python 內 `import caffe`：
```bash
cp -r distribute/python/caffe ~/Library/Python/2.7/lib/python/site-packages/
cp distribute/lib/libcaffe.so.1.0.0-rc3 ~/Library/Python/2.7/lib/python/site-packages/caffe/libcaffe.so.1.0.0-rc3
install_name_tool -change @rpath/libcaffe.so.1.0.0-rc3 ~/Library/Python/2.7/lib/python/site-packages/caffe/libcaffe.so.1.0.0-rc3 ~/Library/Python/2.7/lib/python/site-packages/caffe/_caffe.so
```

### verify build
最後跑下面這行試試看，如果沒有輸出就代表安裝成功了！
```bash
python -c 'import caffe'
```

### install & launch DIGITS
將下面這兩行塞到你的 `.bashrc` 或 `.zshrc` 等類似東西裡面去：
```bash
export DIGITS_ROOT="~/Documents/DIGITS"
export CAFFE_ROOT='~/Documents/caffe'
```

重啟 shell，接著執行：
```bash
git clone https://github.com/NVIDIA/caffe.git $CAFFE_ROOT
cd $DIGITS_ROOT
sudo pip install -r $CAFFE_ROOT/python/requirements.txt
```

接下來 `vim ./digits-devserver` 並把最後一行的開頭 `python` 改為 `python2.7`，然後跑下面這行：
```bash
./digits-devserver
```

看到下面這樣就是啟動成功了！如果出現錯誤，先重複前面編譯並安裝 protobuf 2.6.1 的步驟試試，這邊一定要使用 2.6.1 版本，大於 3.0.0 的版本目前有 bug 無法搭配 DIGITS 使用。
![](/content/images/2017/01/Screen-Shot-2017-01-08-at-11.20.24-PM.png)

接著開啟 http://localhost:5000/ 就會進入 DIGITS 首頁囉，大概長這樣：

![](/content/images/2017/01/Screen-Shot-2017-01-08-at-11.23.43-PM.png)

### remember...
最後再安裝回原本的 Command-Line-Tools：下載並安裝 [Command_Line_Tools_macOS_10.12_for_Xcode_8.2.dmg](http://adcdownload.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.12_for_Xcode_8.2/Command_Line_Tools_macOS_10.12_for_Xcode_8.2.dmg)

## FAQ
###### 1. 碰到下列狀況就是 numpy 版本不對或者衝突了：
```
$ make -j8 pytest
cd python; python -m unittest discover -s caffe/test
dyld: warning, LC_RPATH @executable_path/ in /usr/local/cuda/lib/libcublas.8.0.dylib being ignored in restricted program because of @executable_path
dyld: warning, LC_RPATH @executable_path/ in /usr/local/cuda/lib/libcurand.8.0.dylib being ignored in restricted program because of @executable_path
python(71396,0x7fffefcc13c0) malloc: *** malloc_zone_unregister() failed for 0x7fffefcb7000
RuntimeError: module compiled against API version 0xa but this version of numpy is 0x9
/bin/sh: line 1: 71396 Illegal instruction: 4  python -m unittest discover -s caffe/test
make: *** [pytest] Error 132
```
這時先重新安裝 numpy，然後看一下它裝去哪了：
```bash
sudo -H pip uninstall numpy
sudo -H pip install 'numpy==1.11.3'
pip show numpy
```
在 Location 那一行就是它的 lib 位置，這時打開 `Makefile.config` 找到 `PYTHON_INCLUDE`，把它的第二行 path 改成這邊顯示的位置。

###### 2. 出現 `ImportError: No module named protobuf`, `fatal error 'numpy/arrayobject.h' file not found`
執行下面兩行即可解決
```bash
sudo -H pip uninstall protobuf
sudo -H pip install 'protobuf==3.1.0.post1'
```

### references
* https://gist.github.com/doctorpangloss/f8463bddce2a91b949639522ea1dcbe4
* http://xxuan.me/2016-11-12-install-caffe-under-macos.html
* https://github.com/tensorflow/tensorflow/issues/890
* https://eddiesmo.wordpress.com/2016/12/20/how-to-set-up-caffe-environment-and-pycaffe-on-os-x-10-12-sierra/
* https://github.com/BVLC/caffe/issues/1284#issuecomment-164289484
