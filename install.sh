#!/bin/bash

# Убедитесь, что скрипт запускается с правами суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт с правами суперпользователя (sudo)."
  exit
fi

# Имя виртуального окружения
VENV_NAME="soft"


# 1. Создание виртуального окружения
sudo apt-get install -y python3-venv
echo "Создание виртуального окружения ${VENV_NAME}..."
python3 -m venv "$HOME/$VENV_NAME"

# Активация виртуального окружения
echo "Активация виртуального окружения ${VENV_NAME}..."
source "$HOME/$VENV_NAME/bin/activate"

# Проверка, что окружение активировано (необязательно)
if [ -z "$VIRTUAL_ENV" ]; then
  echo "Ошибка: Виртуальное окружение не было активировано."
  exit 1
fi

# 2. Установка базовых зависимостей
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
libopencore-amrwb-dev gcc screen libomp-dev ssh curl portaudio19-dev nvidia-cuda-toolkit


# Установка Cython
pip install Cython==0.29.37

# 3. Установка CUDA
echo "Установка CUDA..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.6.2/local_installers/cuda-repo-ubuntu2404-12-6-local_12.6.2-560.35.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2404-12-6-local_12.6.2-560.35.03-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2404-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-6

# 4. Установка cuDNN 
echo "Установка cuDNN..."
wget https://developer.download.nvidia.com/compute/cudnn/9.5.0/local_installers/cudnn-local-repo-ubuntu2404-9.5.0_1.0-1_amd64.deb
sudo dpkg -i cudnn-local-repo-ubuntu2404-9.5.0_1.0-1_amd64.deb
sudo cp /var/cudnn-local-repo-ubuntu2404-9.5.0/cudnn-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cudnn

# 5. Установка OpenBLAS
echo "Установка OpenBLAS..."
git clone https://github.com/OpenMathLib/OpenBLAS.git 
cd OpenBLAS && make -j 12 && sudo make install PREFIX=/usr/local/opt/openblas && cd ..

# 6. Установка NumPy
echo "Установка NumPy..."
pip install numpy==1.26.4

# 7. Установка SciPy
echo "Установка SciPy..."
pip install scipy
#Установка NumPy
pip uninstall numpy && pip install numpy==1.26.4
(потому что этот пидор опять не ту версию подсасывает)


# 8. Установка FilterPy
echo "Установка FilterPy..."
git clone https://github.com/rlabbe/filterpy.git -b 1.4.5
cd filterpy && sudo python3 setup.py install && cd ..

# 9. Установка FFmpeg
echo "Установка FFmpeg..."
git clone https://github.com/FFmpeg/FFmpeg.git -b n6.1.2 && git clone https://github.com/FFmpeg/nv-codec-headers.git -b sdk/12.2 
cd nv-codec-headers && make && sudo make install && sudo ldconfig && cd ..
cd FFmpeg && export CFLAGS="-fPIC" && export CXXFLAGS="-fPIC" && ./configure --prefix=/usr/local --enable-shared --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-pic --enable-libx265 --enable-nonfree --enable-cuda-nvcc --enable-cuvid --enable-nvenc && make -j 12 && sudo make install && cd ..



# 10. Установка OpenCV
echo "Установка OpenCV..."
git clone https://github.com/opencv/opencv.git -b 4.11.0 && git clone  https://github.com/opencv/opencv_contrib.git -b 4.11.0
cd opencv && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules .. && make -j 12 && sudo make install && cd ../..

# смотрим путь куда встало опнсв
OPENCV_PATH=$(python3 -c "import cv2; print(cv2.path[0])")
echo "Путь к OpenCV: ${OPENCV_PATH}"
sudo cp -r "${OPENCV_PATH}" "/$VENV_NAME/lib/python3.12/site-packages/cv2"
#sudo cp -r /usr/local/lib/python3.12/dist-packages/cv2 /home/liz/PycharmProjects/SHUM/soft/lib/python3.12/site-packages/cv2

# смотрим путь куда встало
which ffmpeg
sudo cp -r /usr/local/bin/ffmpeg /$VENV_NAME/bin/

sudo cp -r /usr/local/lib/libavdevice* /$VENV_NAME/lib/




# 11. Установка дополнительных библиотек (опционально)
echo "Установка дополнительных библиотек..."
pip install werkzeug uvicorn fastapi pydub matplotlib sounddevice librosa deskew python-multipart PyYAML ultralytics #langchain, llama-cpp-python

pip install git+https://github.com/SiggiGue/pyfilterbank.git

pip uninstall opencv-python

echo "Установка завершена!"
