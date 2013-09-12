#!/bin/tcsh 
# coordstoijk.csh 
# usage: coordstoijk.csh dset xx yy zz 
# where dset is the name of the dataset (AFNI or NIFTI format) 
# xx yy zz are the xyz coordinates (in RAI) 
# output is are the corresponding index coordinates (ijk) 

# example: 

# coordstoijk.csh anat+orig -123.6 -135.4 -62.7 
# ++ Using matrix-vector transformation below: 
# [ 0.93750 0.00000 0.00000 ] [ -123.62900 ] 
# [ 0.00000 0.93750 0.00000 ] [ -135.43400 ] 
# [ 0.00000 0.00000 1.20000 ] [ -62.65850 ] 
# ++ Wrote 1 vectors 
# 0.000000 0.000000 0.000000 

set dset = $1 

set xyz = ($2 $3 $4) 
# placeholder for output ijk coordinates 
set coords = (1 2 3) 

cat_matvec ${dset}::IJK_TO_DICOM_REAL > ijkmat.1D 
# get the ijk coordinates in floating point 
set fcoords = `echo $xyz | Vecwarp -matvec ijkmat.1D -backward -output - ` 
foreach ii ( 1 2 3 ) 
# round off to integer 
set coords[$ii] = `ccalc "int($fcoords[${ii}]+.5)"` 
end 
echo $coords

