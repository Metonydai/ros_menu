#!/bin/bash

set -e

ros2_distro=jazzy

echo "=================================================="
echo " Installing ROS 2 Jazzy"
echo "=================================================="

# ----------------------------------------------------------
# 1. Check Ubuntu version
# ----------------------------------------------------------

source /etc/os-release

if [[ "$VERSION_ID" != "24.04" ]]; then
    echo "ERROR: ROS 2 Jazzy requires Ubuntu 24.04."
    echo "Detected version: $VERSION_ID"
    exit 1
fi

echo "[OK] Ubuntu 24.04 detected."

# ----------------------------------------------------------
# 2. Configure locale
# ----------------------------------------------------------

echo "[INFO] Configuring locale..."

sudo apt update

sudo apt install -y \
    locales \
    software-properties-common \
    curl \
    gnupg \
    lsb-release

sudo locale-gen en_US en_US.UTF-8

sudo update-locale \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

export LANG=en_US.UTF-8

# ----------------------------------------------------------
# 3. Enable Universe repository
# ----------------------------------------------------------

echo "[INFO] Enabling Universe repository..."

sudo add-apt-repository -y universe

sudo apt update

# ----------------------------------------------------------
# 4. Configure ROS 2 APT repository
# ----------------------------------------------------------

echo "[INFO] Configuring ROS 2 repository..."

sudo apt install -y curl

export ROS_APT_SOURCE_VERSION=$(
    curl -fsSL -o /dev/null -w '%{url_effective}' \
    https://github.com/ros-infrastructure/ros-apt-source/releases/latest \
    | awk -F/ '{print $NF}'
)

curl -L -o /tmp/ros2-apt-source.deb \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${UBUNTU_CODENAME}_all.deb"

sudo dpkg -i /tmp/ros2-apt-source.deb

# Update package list after adding ROS repository
sudo apt update

echo "[OK] ROS 2 repository configured."

# ----------------------------------------------------------
# 5. Install ROS 2 Jazzy Desktop
# ----------------------------------------------------------

echo "[INFO] Installing ROS 2 Jazzy Desktop..."

sudo apt install -y \
    ros-${ros2_distro}-desktop

echo "[OK] ROS 2 Jazzy Desktop installed."

# ----------------------------------------------------------
# 6. Install additional ROS packages
# ----------------------------------------------------------

echo "[INFO] Installing additional ROS packages..."

sudo apt install -y \
    ros-${ros2_distro}-rqt \
    ros-${ros2_distro}-turtlesim \
    ros-${ros2_distro}-rmw-cyclonedds-cpp

echo "[OK] Additional ROS packages installed."

# ----------------------------------------------------------
# 7. Install development tools
# ----------------------------------------------------------

echo "[INFO] Installing development tools..."

sudo apt install -y \
    ros-dev-tools \
    python3-colcon-common-extensions \
    python3-vcstool \
    python3-argcomplete \
    python3-rosdep

echo "[OK] Development tools installed."

# ----------------------------------------------------------
# 8. Initialize rosdep
# ----------------------------------------------------------

echo "[INFO] Initializing rosdep..."

if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
else
    echo "[INFO] rosdep already initialized."
fi

rosdep update

echo "[OK] rosdep initialized."

# ----------------------------------------------------------
# 9. Verify ROS 2 installation
# ----------------------------------------------------------

echo "[INFO] Verifying ROS 2 installation..."

source /opt/ros/${ros2_distro}/setup.bash

echo "ROS_VERSION: $ROS_VERSION"
echo "ROS_DISTRO: $ROS_DISTRO"

echo ""
echo "Checking ROS 2 command..."

if ! command -v ros2 > /dev/null 2>&1; then
    echo "ERROR: ROS 2 installation failed."
    exit 1
fi

echo "[OK] ROS 2 command available."

echo ""
echo "Checking DDS packages..."

ros2 pkg list | grep -E \
    'rmw_cyclonedds_cpp|rmw_fastrtps_cpp'

# ----------------------------------------------------------
# 10. Installation completed
# ----------------------------------------------------------

echo ""
echo "=================================================="
echo " ROS 2 Jazzy installation completed successfully!"
echo "=================================================="

echo ""
echo "ROS installation path:"
echo "/opt/ros/${ros2_distro}"

echo ""
echo "To manually enable ROS 2 Jazzy:"
echo "source /opt/ros/jazzy/setup.bash"

echo ""