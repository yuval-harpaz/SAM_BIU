install instructions
put the SAM executable files (including SvlPeak) in /home/megadmin/bin



http://afni.nimh.nih.gov/pub/dist/HOWTO//howto/ht00_inst/html/index.shtml

in the home directory create a directory called abin

extract the linux_gcc33_64.tgz file and move the content of the linux_gcc33_64 file into abin

go to the home directory, view hidden files, open .bashrc file

add this line to the end of the file    export PATH=$PATH:/home/megadmin/abin


to work with MNI averaged brain:
copy MNI directory to Documants directory

in a terminal write
cd ~Documents/MNI/icbm452_atlas_air12
afni

to work with dicoms one has to convert them with to3d
http://kurage.nimh.nih.gov/meglab/Meg/Brainhull
if converting to dicom doesn't work use SPM8, dicom import.


to overlay svl beamformer images on MRI the MRI has to be aligned.
first the fiducial points (tags) have to be defined on the MRI
use define datamode, plugins, edit tagset
select a dataset (MRI) on the top left corner
write a name of a text file such as the attached example MNI305.tag and click read
click on Nasion, select the spot on the MRI and click set, repeat for the left and right ear and click save.

to align the MRI install brainhull pack (taken from http://kurage.nimh.nih.gov/meglab/Meg/Brainhull)
put the zipped file in your home directory, and in a terminal write:
tar -xzvf brainhull-1.7.tgz
cd brainhull
make
sudo make install  #will require a password
in synaptic package manager search for numpy, mark python-numpy for installation and whatever additional files it askes for. click apply.
when all is set, align the anat MRI to ortho by these two lines (from http://kurage.nimh.nih.gov/meglab/Meg/Brainhull):
libdir=`brainhull -p`
3dTagalign -prefix ./ortho -master $libdir/master+orig anat+orig

to display it on afni
open afni, click underlay and choose ortho
click overlay and choose the .svl file
to change the scale click define overlay, usually you have to change the order of magnitude of scale- under the scale see **, click and choose 1.
to orient the MRI to fit to the functional data go to define data mode, choose Nudge dataset
click and choose dataset and play with buttons, change parameters and nudge / undo antil it fits, then Do All and quit.
for most uses the coordinate system should be changed to PRI (posterior right inferior get positive values). to set it go to define data mode, plugins, coord order.



