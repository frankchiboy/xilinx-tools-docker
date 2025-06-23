# Xilinx Vivado Docker Environment for ZedBoard

This project provides a Docker-based Xilinx Vivado 2020.2 development environment optimized for the ZedBoard (Zynq-7000).

## 🚀 Key Improvements

Compared to the original project, this fork introduces the following key improvements:

- **✅ Fixed Installation Errors**: Resolved the critical "invalid Modules" error during Vivado installation.
- **✅ ZedBoard Optimization**: Specifically tailored for the Zynq-7000 series, removing unnecessary modules.
- **✅ Verified Usability**: Ensured Vivado 2020.2 works correctly in the Docker environment.
- **✅ Automatic Download**: The original project design automatically downloads the Vivado installer from ESnet, no manual handling required.
- **✅ Comprehensive Testing**: Provides a verified build process and usage instructions.

**Original Project Design**：
- Intelligent download mechanism: prioritizes local files, otherwise downloads from ESnet.
- However, it had module configuration errors causing installation failures.

**Advantages of This Version**：
- Fixed all known installation issues.
- Optimized specifically for ZedBoard.
- Includes a complete troubleshooting guide.

## System Requirements

- Docker Desktop
- At least 200GB of available disk space
- 8GB+ RAM recommended
- Stable internet connection
- **Apple Silicon Support**：This project can run on Apple Silicon (M1/M2) but requires the `--platform=linux/amd64` flag to emulate the x86_64 architecture, as Vivado does not support ARM.

## Quick Start

**Build Process Overview**：
- Original project design: Automatically downloads the Vivado installer (approximately 46GB, download speed depends on your network).
- This fork: Fixed module configuration errors and optimized for ZedBoard.

### 1. Automatic Download and Build
```bash
# Build the Docker image (automatically downloads the Vivado installer)
docker build --platform=linux/amd64 -t xilinx-tools-test .
```

### 2. Start Using
```bash
# Launch the development environment
docker run -it xilinx-tools-test
```

**Note**：The first build will automatically download a 46GB Vivado installer. Ensure a stable internet connection and sufficient disk space.

## Detailed Usage Instructions

### Build Options
**Important Notes**：
- **Build Time**：Approximately 30-60 minutes
- **Image Size**：Approximately 167GB (after cleaning temporary files)
- **Platform**：Must specify `linux/amd64` as Vivado does not support ARM.

**Standard Build**：
```bash
docker build --platform=linux/amd64 -t xilinx-tools-test .
```

### Build Process Monitoring
During the build process, you will see the following main steps:
1. Install system dependencies
2. Automatically download the Vivado installer (approximately 46GB)
3. Extract the installer
4. Run the Vivado installation (most time-consuming step)
5. Clean up installation files

## Usage

### 1. Launch the Container
```bash
# Launch in interactive mode
docker run -it xilinx-tools-test

# Launch with platform specification (Apple Silicon Mac)
docker run --platform=linux/amd64 -it xilinx-tools-test
```

### 2. Run Vivado Directly
```bash
# Check Vivado version
docker run -it xilinx-tools-test vivado -version

# Launch Vivado GUI (requires X11 forwarding)
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix xilinx-tools-test vivado
```

### 3. Mount a Working Directory
```bash
# Mount a local directory to the container to save project files
docker run -it -v /path/to/your/projects:/workspace xilinx-tools-test
```

### 4. Long-Term Usage Recommendations

To make the development environment reusable and uninterrupted, it is recommended to create a "persistent container" and mount the local working directory:

```bash
# Create a named container and mount the local project folder for the first time
# Replace /path/to/your/projects with the path to your local project folder

docker run --platform=linux/amd64 -it --name zedboard-dev -v /path/to/your/projects:/workspace xilinx-tools-test
```

- `--name zedboard-dev`: Specifies the container name for easier management later.
- `-v /path/to/your/projects:/workspace`: Mounts the local project folder to `/workspace` inside the container for easy access and file synchronization.

To restart and enter the same container each time:

```bash
docker start zedboard-dev
docker exec -it zedboard-dev bash
```

This preserves all installations, settings, and project files, ensuring an uninterrupted development workflow.

## Troubleshooting

### Common Issues

#### 1. Missing Installer File
**Error**：`No such file or directory: /vivado-installer/install/xsetup`  
**Cause**：Missing Vivado installer file  
**Solution**：
- This project automatically downloads `Xilinx_Unified_2020.2_1118_1232.tar.gz`, no manual handling required.
- Check your internet connection.

#### 2. Module Configuration Error
**Error**：`The value specified in the configuration file for Modules (...) is not valid`  
**Solution**：This project has fixed the configuration file to install only the `Zynq-7000:1` module required for ZedBoard.

#### 3. Platform Mismatch Warning
**Warning**：`platform (linux/amd64) does not match detected host platform (linux/arm64/v8)`  
**Solution**：Normal for Apple Silicon Mac. Add the `--platform=linux/amd64` flag.

#### 4. Long Build Time
**Issue**：Build process stuck at the Vivado installation step  
**Explanation**：Normal behavior. Vivado installation takes 20-40 minutes. Please be patient.

#### 5. Insufficient Disk Space
**Error**：`no space left on device`  
**Solution**：
- Clean Docker cache：`docker system prune -a`
- Ensure at least 200GB of available space.

### Verify Installation
```bash
# Check Vivado installation
docker run -it xilinx-tools-test bash -c 'which vivado && vivado -version'

# Check supported devices
docker run -it xilinx-tools-test bash -c 'ls /tools/Xilinx/Vivado/2020.2/data/parts/xilinx/zynq*'
```

## Development Environment Features

- ✅ **Vivado 2020.2 WebPACK**：Free version, supports Zynq-7000
- ✅ **ZedBoard Optimization**：Installs only necessary modules, saving space and time
- ✅ **Docker Containerization**：Isolated environment, no host system pollution
- ✅ **Cross-Platform**：Supports Linux、macOS、Windows
- ✅ **One-Click Build**：Automated installation process

## Technical Specifications

- **Base Image**：Ubuntu 22.04 (Jammy)
- **Vivado Version**：2020.2 WebPACK
- **Supported Devices**：Zynq-7000 series
- **Installation Path**：`/tools/Xilinx/Vivado/2020.2/`
- **Image Size**：Approximately 167GB

## License

- This project's code is open source.
- Xilinx Vivado software must comply with AMD/Xilinx's licensing terms.
- Users must obtain a valid license for Vivado.

## Contributions

We welcome Issues and Pull Requests to improve this project!

## Acknowledgments

This project is based on [ESnet's xilinx-tools-docker](https://github.com/esnet/xilinx-tools-docker). Thanks to the original authors for their excellent foundational work.

Key contributions:
- Fixed Vivado installation issues in the original project
- Included Vivado installer to resolve ESnet private network download restrictions
- Optimized for ZedBoard development
- Provided complete testing and usage documentation
