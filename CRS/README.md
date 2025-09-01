# CRS

## 4/24/2024

The first day to write. The whole thing is about setting up a small sever with a 22.04 version Ubuntu in my tutor's office.
There were two problems:

* Someone has to type "dhcilent" manually to connect the internet each time it reboots. I have huge data to deal with so the data is on the sever and I wrok remotely, so I have to ask my tutor to do the re-connecting every time when something goes wrong, which is really annoying.
* I need to use scvi-tools to eliminate the match effect between scRNA-seq datasets. It require GPU acceleration, thus a driver for NVIDIA RTX3080 is required.

### Automatic internet connection

I followed this direction: <https://blog.csdn.net/weixin_52018852/article/details/132331351#:~:text=dhclient%E8%B4%9F%E8%B4%A3%E4%B8%8EDHCP%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%80%9A%E4%BF%A1%EF%BC%8C%E5%8D%8F%E5%95%86IP%E5%9C%B0%E5%9D%80%E3%80%81%E5%AD%90%E7%BD%91%E6%8E%A9%E7%A0%81%E3%80%81%E7%BD%91%E5%85%B3%E7%AD%89%E9%85%8D%E7%BD%AE%E5%8F%82%E6%95%B0%EF%BC%8C%E5%B9%B6%E5%B0%86%E8%BF%99%E4%BA%9B%E9%85%8D%E7%BD%AE%E5%BA%94%E7%94%A8%E5%88%B0%E7%B3%BB%E7%BB%9F%E7%BD%91%E7%BB%9C%E6%8E%A5%E5%8F%A3%E3%80%82%20%E5%9C%A8,Linux%E7%B3%BB%E7%BB%9F%20%E4%B8%AD%EF%BC%8C%E5%8F%AF%E4%BB%A5%E4%BD%BF%E7%94%A8systemd%E6%9D%A5%E5%AE%9E%E7%8E%B0%E5%BC%80%E6%9C%BA%E8%87%AA%E5%8A%A8%E5%BC%80%E5%90%AF%E7%BD%91%E5%8D%A1%E5%B9%B6%E5%90%AF%E5%8A%A8dhclient%E6%9C%8D%E5%8A%A1%E3%80%82>, which worked well.

### NVIDIA driver and CUDA

1. Download the right version of the driver. Check the version here <https://www.nvidia.com/Download/index.aspx>. Transfer the file to the sever and `cd` to that directory. Run `sudo sh [filename]` to start installation. You can also use

    ```linux
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:graphics-drivers/ppa
    sudo apt-get update
    sudo apt-cache search nvidia-*  # see avalable versions
    sudo apt-get install nvidia-[version]
    # OR
    ubuntu-drivers devices  # see which driver is recommended
    sudo apt install nvidia-driver-[version]
    sudo apt install nvidia-cuda-toolkit
    ```

2. Ban X sever by `sudo init 3`. Let the installer ban nouveau, the original graphic driver for Ubuntu, and update initramfs. Important, no rebooting now, or the server might not come alive again and you have to go into the recovery mode and remove the config files that forbid nouveau. If you can reboot successfully, the installation is finished.
3. In your conda environment,

    ```linux
    # NVIDIA driver version 535.161.08, CUDA version 11.5
    conda install scvi-tools==0.20.1
    conda install pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.7 -c pytorch -c nvidia
    # These versions work for me
    ```

4. When importing and using scvi, you may enconter some errors. If failed importing scvi, try to use an older version of scvi and also jax and jaxlib. If can't use GPU when training the model, try to install another version of CUDA Toolkit. cuDNN is not required in scvi.
