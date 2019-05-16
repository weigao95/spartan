#!/bin/bash

set -euxo pipefail

# The pytorch
pip install https://download.pytorch.org/whl/cu100/torch-1.1.0-cp27-cp27mu-linux_x86_64.whl
pip install torchvision

# The open3d
pip install open3d-python==0.5.0.0

# For maskrcnn
pip install pycocotools
pip install ninja yacs cython matplotlib tqdm

# The maskrcnn itself
# Note that this version doesn't need aped
root_dir=$(pwd)
mkdir maskrcnn_src_install
workdir=$root_dir/maskrcnn_src_install

install_maskrcnn()
{   cd $workdir
    git clone https://github.com/weigao95/maskrcnn-benchmark.git
    cd maskrcnn-benchmark
    python setup.py build
    python setup.py install
}

install_maskrcnn