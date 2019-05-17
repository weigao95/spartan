#!/bin/bash

install_maskrcnn()
{   
    cd ${HOME}
    mkdir maskrcnn_src_install
    cd maskrcnn_src_install
    git clone https://github.com/weigao95/maskrcnn-benchmark.git
    cd ~/maskrcnn_src_install/maskrcnn-benchmark
    sudo python setup.py build
    sudo python setup.py install
}

install_maskrcnn
