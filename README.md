# Xilinx Vivado Docker Environment for ZedBoard

本專案提供一個基於 Docker 的 Xilinx Vivado 2020.2 開發環境，專為 ZedBoard (Zynq-7000) 開發板優化。

## 系統需求

- Docker Desktop
- 至少 200GB 可用磁碟空間
- 8GB+ RAM 建議
- 穩定的網路連線

## 準備工作

### 1. 下載 Vivado 安裝檔
**重要：您必須自行從 Xilinx 官網下載安裝檔**

1. 前往 [Xilinx 下載頁面](https://www.xilinx.com/support/download.html)
2. 註冊並登入 AMD/Xilinx 帳號
3. 下載 `Xilinx_Unified_2020.2_1118_1232.tar.gz` (約 46GB)
4. 將檔案放入 `vivado-installer/` 目錄

### 2. 檔案結構確認
```
xilinx-tools-docker/
├── Dockerfile
├── entrypoint.sh
├── vivado-installer/
│   ├── Xilinx_Unified_2020.2_1118_1232.tar.gz  ← 您需要下載
│   ├── install_config_vivado.2020.2.txt
│   └── install_config_vivado.2025.1.txt
├── patches/
└── README.md
```

## 建置 Docker 映像檔

### 重要注意事項
- **建置時間**：約 30-60 分鐘
- **映像檔大小**：約 167GB
- **平台**：必須指定 `linux/amd64`

### 建置指令
```bash
# 切換到專案目錄
cd xilinx-tools-docker

# 建置映像檔（Apple Silicon Mac 必須加 --platform=linux/amd64）
docker build --platform=linux/amd64 -t xilinx-tools-test .
```

### 建置過程監控
建置過程中會看到以下主要步驟：
1. 安裝系統相依套件
2. 複製 Vivado 安裝檔案 (約 46GB)
3. 解壓縮安裝檔案
4. 執行 Vivado 安裝 (最耗時)
5. 清理安裝檔案

## 使用方式

### 1. 啟動容器
```bash
# 互動模式啟動
docker run -it xilinx-tools-test

# 指定平台啟動 (Apple Silicon Mac)
docker run --platform=linux/amd64 -it xilinx-tools-test
```

### 2. 直接執行 Vivado
```bash
# 檢查 Vivado 版本
docker run -it xilinx-tools-test vivado -version

# 啟動 Vivado GUI (需要 X11 forwarding)
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix xilinx-tools-test vivado
```

### 3. 掛載工作目錄
```bash
# 將本機目錄掛載到容器，保存專案檔案
docker run -it -v /path/to/your/projects:/workspace xilinx-tools-test
```

### 4. 長期使用建議
```bash
# 建立具名容器，方便重複使用
docker run -it --name zedboard-dev xilinx-tools-test

# 重新進入容器
docker start zedboard-dev
docker exec -it zedboard-dev bash
```

## 故障排除

### 常見問題

#### 1. 安裝檔案未找到
**錯誤**：`No such file or directory: /vivado-installer/install/xsetup`
**解決**：確認 `Xilinx_Unified_2020.2_1118_1232.tar.gz` 已放入 `vivado-installer/` 目錄

#### 2. 模組配置錯誤
**錯誤**：`The value specified in the configuration file for Modules (...) is not valid`
**解決**：本專案已修正配置檔，只安裝 ZedBoard 需要的 `Zynq-7000:1` 模組

#### 3. 平台不匹配警告
**警告**：`platform (linux/amd64) does not match detected host platform (linux/arm64/v8)`
**解決**：Apple Silicon Mac 正常現象，加上 `--platform=linux/amd64` 參數即可

#### 4. 建置時間過長
**現象**：建置卡在 Vivado 安裝步驟
**說明**：正常現象，Vivado 安裝需要 20-40 分鐘，請耐心等待

#### 5. 磁碟空間不足
**錯誤**：`no space left on device`
**解決**：
- 清理 Docker 快取：`docker system prune -a`
- 確保至少有 200GB 可用空間

### 驗證安裝
```bash
# 檢查 Vivado 安裝
docker run -it xilinx-tools-test bash -c 'which vivado && vivado -version'

# 檢查支援的裝置
docker run -it xilinx-tools-test bash -c 'ls /tools/Xilinx/Vivado/2020.2/data/parts/xilinx/zynq*'
```

## 開發環境特色

- ✅ **Vivado 2020.2 WebPACK**：免費版本，支援 Zynq-7000
- ✅ **ZedBoard 優化**：只安裝必要模組，節省空間和時間
- ✅ **Docker 容器化**：隔離環境，不污染主機系統
- ✅ **跨平台**：支援 Linux、macOS、Windows
- ✅ **一鍵建置**：自動化安裝流程

## 技術規格

- **基礎映像檔**：Ubuntu 22.04 (Jammy)
- **Vivado 版本**：2020.2 WebPACK
- **支援裝置**：Zynq-7000 系列
- **安裝路徑**：`/tools/Xilinx/Vivado/2020.2/`
- **映像檔大小**：約 167GB

## 授權聲明

- 本專案程式碼採用開源授權
- Xilinx Vivado 軟體需遵循 AMD/Xilinx 的授權條款
- 使用者需自行取得 Vivado 的合法授權

## 貢獻

歡迎提交 Issue 和 Pull Request 來改善這個專案！
