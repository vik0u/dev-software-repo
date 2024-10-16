# dev-software-repo
dev soft for ubuntu 24.04

CUDA 12.6, cuDNN, FFmpeg, FilterPy, NumPy, OpenBLAS, OpenCV, SciPy and other installation  on a clean Ubuntu 24.04

**This installer is intended for use on a clean Ubuntu 24.04 system. Please ensure that you do NOT have these packages already installed, as this may cause dependency issues.**

# versions:
- `Cython==0.29.37`
- `CUDA==12.6.2`
- `cuDNN==9.5.0`
- `NumPy==1.26.5`
- `SciPy==1.11.4`
- `FilterPy==1.4.5`
- `OpenCV=4.10.0`
- `OpenBLAS 0.3.28.dev`

# usage:
1. Make sure you have Git installed:
   ```bash
   sudo apt update && sudo apt install git
   ```
   
2. Clone the repository into the `soft` folder:
   ```bash
   git clone https://github.com/vik0u/dev-software-repo.git soft
   ```
3. Navigate to the cloned repository folder and run the installation script:
   ```bash
   cd soft && sudo bash install.sh
   ```
# contributing
Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

# acknowledgments
Thank you for using this repository! Happy coding!
