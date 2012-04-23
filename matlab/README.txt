Matlab scripts to support SAM analysis
start with prepare4SAM


fitIndMRI
intended for MEG studies with no individual MRIs, creates MRI image for all subjects from one template.
requires SPM8, make sure the cannonical folder is there with single_subj_T1.nii in it
takes single_subj_T1.nii template MRI (was supplied with SPM8 and should be in a floder call ed canonical)
it changes it's proportion according to the 3 fiducial points and vertex of hs_file (perpendicular to fiducials plain)
in order to fit the MRI to the headshape.

fixVisTrig
unfinished function
intended to look for 2048 visual trigger and a preceding E' trigger.
it writes the preceding value at the onset time of the visual trigger.
at the offset of the visual trigger it writes 300+preceding value

point_to_line
required for fitIndMRI

prepare4SAM
an example for a script that prepares the data of one subject for SAM.
it requires data in folders with subjects names (e.g., b026), sampling rate (sr) file name (c,rf*) a path to the parent directory and bad channels to be replaced with zeros [74 204].

readTrig_BIU
just reads the trigger channel

rewriteTrig
rewrites the trigger channel to a copied datafile beggining with tf_ for trigger fixed.
designed to eliminate unnecessary triggers and to set conditions at their exact time.
use readTrig_BIU, manipulate the trigger as you wish (may be with fixVisTrig) and then rewriteTrig.

virtualsensor is a script used by dr. Robinson to display the output of SAMvs.
it is used regularly for epilepsy data, after finding local maxima on svl image files.

