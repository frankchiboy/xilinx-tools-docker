FROM ubuntu:22.04

# Update system and install required dependencies
RUN apt-get update && apt-get install -y \
    libx11-6 libxrender1 libxtst6 libxi6 libxrandr2 libxss1 libxinerama1 libxcursor1 libxcomposite1 libxdamage1 libxfixes3 libgtk-3-0 libasound2 \
    libpython3.8 libpython3.8-dev python3 python3-pip sox && rm -rf /var/lib/apt/lists/*

# Set environment variable to include dynamic library path
ENV LD_LIBRARY_PATH="/tools/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3/lib:$LD_LIBRARY_PATH"

# Fix Python executable path issue
RUN mv /tools/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3 /tools/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3.bak && \
    echo "#!/bin/bash" > /tools/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3 && \
    echo "/usr/bin/python3 \"$@\"" >> /tools/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3 && \
    chmod +x /tools/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3

# Set working directory
WORKDIR /workspace

# Default to bash
CMD ["/bin/bash"]
