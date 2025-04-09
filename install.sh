#!/bin/bash
pip install streamlit==0.73.1
pip install albumentations==0.4.3
pip install omegaconf==2.0.0
pip uninstall transformers
pip install transformers==4.31.0 tokenizers==0.13.3 --prefer-binary
pip install pytorch-lightning==1.5.0
pip install test-tube==0.7.5