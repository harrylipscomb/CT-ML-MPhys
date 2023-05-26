# -*- coding: utf-8 -*-
"""
Created on Tue May  2 15:07:31 2023

@author: HMXIF Remote
"""
import os
from skimage.util import img_as_uint
import tifffile as tif
from tifffile import imread
from matplotlib import pyplot as plt
import tensorflow as tf
import numpy as np

train_width = 2000
train_height = 2000

test_width = 2000
test_height = 2000

x_patches = 5
y_patches = 5

patch_train_width = int(train_width/x_patches)
patch_train_height = int(train_height/y_patches)

patch_test_width = int(test_width/x_patches)
patch_test_height = int(test_height/y_patches)

test_scan_path = 'Z:/Projects/Amin-Anuj-Fibres/ML_report_test_short/test_scan/'
ground_truth_test_path = 'Z:/Projects/Amin-Anuj-Fibres/ML_report_test_short/test_truth/'

load_model_location = "Z:/Projects/Amin-Anuj-Fibres/ML_report_test_short/model/trained" # POSITION WHERE THE MODEL IS TO SAVED

model = tf.keras.models.load_model(load_model_location)


def create_patches( imgs, num_x_patches, num_y_patches ):
    ''' Create a list of images patches out of a list of images
    Args:
        imgs: list of input images
        num_x_patches: number of patches in the X axis
        num_y_patches: number of patches in the Y axis
        
    Returns:
        list of image patches
    '''
    original_size = imgs[0].shape
    patch_width = original_size[ 0 ] // num_x_patches
    patch_height = original_size[ 1 ] // num_y_patches
    
    patches = []
    for n in range( 0, len( imgs ) ):
        image = imgs[ n ]
        for i in range( 0, num_x_patches ):
            for j in range( 0, num_y_patches ):
                patches.append( image[ i * patch_width : (i+1) * patch_width,
                                      j * patch_height : (j+1) * patch_height ])#.astype(dtype='uint8') ) # All .astype comments can be removed for greater # of files (but ML is slower)
    return patches


def prediction_nth_slice(n, number_patches_per_tiff, predictions):
    
    tiff_number_added = n*number_patches_per_tiff
    file_name = ground_truth_test_filenames[n]
    
    prediction = np.block([[predictions[0+tiff_number_added,:,:,0], predictions[1+tiff_number_added,:,:,0], predictions[2+tiff_number_added,:,:,0], predictions[3+tiff_number_added,:,:,0], predictions[4+tiff_number_added,:,:,0]],
                       [predictions[5+tiff_number_added,:,:,0], predictions[6+tiff_number_added,:,:,0], predictions[7+tiff_number_added,:,:,0], predictions[8+tiff_number_added,:,:,0], predictions[9+tiff_number_added,:,:,0]],
                       [predictions[10+tiff_number_added,:,:,0], predictions[11+tiff_number_added,:,:,0], predictions[12+tiff_number_added,:,:,0], predictions[13+tiff_number_added,:,:,0], predictions[14+tiff_number_added,:,:,0]],
                       [predictions[15+tiff_number_added,:,:,0], predictions[16+tiff_number_added,:,:,0], predictions[17+tiff_number_added,:,:,0], predictions[18+tiff_number_added,:,:,0], predictions[19+tiff_number_added,:,:,0]],
                       [predictions[20+tiff_number_added,:,:,0], predictions[21+tiff_number_added,:,:,0], predictions[22+tiff_number_added,:,:,0], predictions[23+tiff_number_added,:,:,0], predictions[24+tiff_number_added,:,:,0]]])

    return [prediction, file_name]

# Now we load some unseen images for testing
test_filenames = [x for x in os.listdir( test_scan_path ) if x.endswith(".tif")]

print( 'Available test images: ' + str( len(test_filenames)) )

# Read test images
test_img = [ img_as_uint( tif.imread( test_scan_path + x ) ) for x in test_filenames]

ground_truth_test_filenames = [x for x in os.listdir( ground_truth_test_path ) if x.endswith(".tif")]

ground_truth_test_img = [ img_as_uint( imread( ground_truth_test_path + x ) ) for x in ground_truth_test_filenames ]    #CHANGE IF MORE THAN 1 TEST WANTED
#ground_truth_test_img = [ img_as_uint( imread( ground_truth_test_path + ground_truth_test_filenames[0] ) )  ]

ground_truth_test_patches = create_patches(ground_truth_test_img, x_patches, y_patches)
test_patches = create_patches(test_img, x_patches, y_patches)

"""We can evaluate the network performance in test using both the MSE and MAE metrics."""

number_of_patches = x_patches*y_patches*len(ground_truth_test_img)
input_shape = ( patch_test_width, patch_test_height, number_of_patches )
input_shape_2 = (number_of_patches, 400, 400, 1)
# Evaluate trained network on test images
X_test = ground_truth_test_patches  #CHANGE IF MORE THAN 1 TEST WANTED
X_test = np.asarray(X_test)/65535
X_test = np.reshape(X_test, input_shape_2)

Y_test = np.asarray(test_patches)/65535 # gVXR
Y_test = np.reshape(Y_test, input_shape_2)

# Evaluate the model on the test data using `evaluate`
print('\n# Evaluate on test data')
results = model.evaluate(Y_test, X_test , batch_size=1)
#results = model.evaluate(X_test, Y_test , batch_size=125)
print('test loss, test MAE:', results)

"""And also display some patches for qualitative evaluation."""

predictions = model.predict(Y_test)

print('predictions shape:', predictions.shape)

# Display corresponding first 3 patches
    
def demonstrate_comparison(slice_numbers):
    
    first_slice = slice_numbers[0]
    second_slice = slice_numbers[1]
    third_slice = slice_numbers[2]
    
    prediction_1, name_1 = prediction_nth_slice(first_slice, 25, predictions)
    prediction_2, name_2 = prediction_nth_slice(second_slice, 25, predictions)
    prediction_3, name_3 = prediction_nth_slice(third_slice, 25, predictions)
    
    plt.figure(figsize=(15,15))
    plt.tick_params(axis='both', which='major', labelsize=17)
    plt.subplot(3, 3, 1)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( ground_truth_test_img[first_slice], 'gray' )
    plt.title('Ground Truth', fontsize=18)
    plt.ylabel(name_1, fontsize=18)
    plt.subplot(3, 3, 2)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( test_img[first_slice], 'gray' )
    plt.title( 'gVXR Scan', fontsize=18 )
    plt.subplot(3, 3, 3)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( prediction_1, 'gray' )
    plt.title( 'ML Prediction', fontsize=18 )
    
    plt.subplot(3, 3, 4)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( ground_truth_test_img[second_slice], 'gray' )  
    plt.ylabel(name_2, fontsize=18)
    plt.subplot(3, 3, 5)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( test_img[second_slice], 'gray' )
    plt.subplot(3, 3, 6)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( prediction_2, 'gray' )
    
    plt.subplot(3, 3, 7)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( ground_truth_test_img[third_slice], 'gray' )
    plt.ylabel(name_3, fontsize=18)
    plt.subplot(3, 3, 8)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)
    plt.imshow( test_img[third_slice], 'gray' )
    plt.subplot(3, 3, 9)
    plt.xticks(fontsize=15)
    plt.yticks(fontsize=15)

    plt.imshow( prediction_3, 'gray' )
    plt.savefig('9 image comparison, 50 tiffs.png', dpi=400)
    plt.show()

demonstrate_comparison([1,10,19])