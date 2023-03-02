# CT-ML-MPhys

Series of code files related to surface roughness chracterisation using surface generation on ImageJ, CT scans and machine learning. The overall workflow of the project:

1. Dozens of rough surface files (both .stl and .tif) are generated using the ImageJ macro 'Generate_Surface_1.3 (Cleaning Option).ijm' with a binary-style surface.
2. These are scanned using a digital twin of the Nikon XTH 225 CT scanner with code from gvxr on Python 'gvxr_basics.py'.
3. These scans are used within U-Net convolution neural networks to train a machine to improve the resolution of these scanned images, improving the quality of the output from the scanner and learning more about the object being scanned. 
