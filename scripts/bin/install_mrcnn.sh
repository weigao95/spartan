#!/bin/bash

install_maskrcnn()
{   cd ~/maskrcnn_src_install/maskrcnn-benchmark
    sudo python setup.py build
    sudo python setup.py install
}

install_maskrcnn
