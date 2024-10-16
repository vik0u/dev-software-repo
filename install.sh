#!/bin/bash

# Убедитесь, что скрипт запускается с правами суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт с правами суперпользователя (sudo)."
  exit
fi

# 1. Установка базовых зависимостей
echo "Обновление системы и установка базовых зависимостей..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-utils autoconf automake build-essential cmake \
libass-dev libfreetype6-dev libsdl2-dev libtool libva-dev libvdpau-dev \
libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config \
texinfo wget zlib1g-dev nasm yasm libx264-dev libx265-dev libnuma-dev \
libvpx-dev libfdk-aac-dev libmp3lame-dev libopus-dev unzip libjpeg-dev \
libpng-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev \
libv4l-dev libxvidcore-dev libgtk-3-dev libatlas-base-dev gfortran python3 \
python3-dev python3-pip libgtk2.0-dev libtbb-dev qt5-doc qtcreator \
qtbase5-dev qt5-qmake x264 v4l-utils libprotobuf-dev protobuf-compiler \
libjpeg8-dev libfaac-dev libtheora-dev libopencore-amrnb-dev \
libopencore-amrwb-dev gcc screen libomp-dev ssh curl portaudio19-dev

# Установка Cython
pip install Cython==0.29.37 --break-system-packages

# 2. Установка CUDA
echo "Установка CUDA..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.6.2/local_installers/cuda-repo-ubuntu2404-12-6-local_12.6.2-560.35.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2404-12-6-local_12.6.2-560.35.03-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2404-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-6

# 3. Установка cuDNN 
echo "Установка cuDNN..."
wget https://developer.download.nvidia.com/compute/cudnn/9.5.0/local_installers/cudnn-local-repo-ubuntu2404-9.5.0_1.0-1_amd64.deb
sudo dpkg -i cudnn-local-repo-ubuntu2404-9.5.0_1.0-1_amd64.deb
sudo cp /var/cudnn-local-repo-ubuntu2404-9.5.0/cudnn-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cudnn

# 4. Установка OpenBLAS
echo "Установка OpenBLAS..."
git clone https://github.com/OpenMathLib/OpenBLAS.git 
cd OpenBLAS && make -j 12 && sudo make install PREFIX=/usr/local/opt/openblas && cd ..

# 5. Установка NumPy
echo "Установка NumPy..."
git clone https://github.com/numpy/numpy.git -b v1.26.5 
cd numpy && git submodule update --init && cd ..

# Копирование файла site.cfg из папки numpy_contrib в папку numpy
cp numpy_contrib/site.cfg numpy/

cd numpy && sudo python3 setup.py build -j 12 install --prefix /usr/local && cd ..

# 6. Установка SciPy
echo "Установка SciPy..."
git clone https://github.com/scipy/scipy.git -b v1.11.4 && git submodule update --init
sudo pip3 install pybind11 pythran --break-system-packages
cp scipy_contrib/site.cfg scipy/
cp scipy_contrib/flapack_sym_herm.pyf.src scipy/linalg/
cd scipy && sudo python3 setup.py build -j 12 install --prefix /usr/local && cd ..

# 7. Установка FilterPy
echo "Установка FilterPy..."
git clone https://github.com/rlabbe/filterpy.git -b 1.4.5
cd filterpy && sudo python3 setup.py install && cd ..

# 8. Установка FFmpeg
echo "Установка FFmpeg..."
git clone https://github.com/FFmpeg/nv-codec-headers.git && git clone https://github.com/FFmpeg/FFmpeg.git
cd nv-codec-headers && make && sudo make install && sudo ldconfig
cd FFmpeg && ./configure --prefix="$HOME/soft/FFmpeg" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree --enable-cuda-nvcc --enable-cuvid --enable-nvenc && make -j 12 && sudo make install && cd ..

# 9. Установка OpenCV
echo "Установка OpenCV..."
git clone https://github.com/opencv/opencv.git -b 4.10.0 && git clone  https://github.com/opencv/opencv_contrib.git -b 4.10.0
cd opencv && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules .. && make -j 12 && sudo make install && cd ../..

# 10. Установка дополнительных библиотек (опционально)
echo "Установка дополнительных библиотек..."
pip install langchain werkzeug uvicorn fastapi llama-cpp-python pydub matplotlib sounddevice librosa deskew python-multipart --break-system-packages

pip install git+https://github.com/SiggiGue/pyfilterbank.git

echo "Установка завершена!"
