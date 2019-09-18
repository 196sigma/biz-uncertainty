import os
jpeg_list = [x for x in os.listdir('.') if x[-4:] == 'jpeg']
png_list = [x[:-4]+'png' for x in jpeg_list]

for x in jpeg_list:
    os.rename(x, x[:-4] + 'png')
