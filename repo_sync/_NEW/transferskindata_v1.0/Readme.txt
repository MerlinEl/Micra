Copyright 2015, Michael Lawler
	
Email:		archangel35757@yahoo.com
	
Title:		Transfer Skin Data
	
Version:	1.0
 (Released 14 March 2016)

Description:	This script allows a user to swap out skeletons by transferring Skin Modifier data. 
		This is 
done by saving skin envelope data on the current skeleton and then reloading
		the skin modifier
 data (bones and skin weights) onto a new skeleton merged into the 
		scene (that replaced the old skeleton).

Assumptions:
- This script assumes that you have a fully rigged and skinned model.

- This script assumes that you do not have any pre-existing custom attributes on your skinned mesh objects or rootNode.
  As this script deletes these temporary custom attributes by index number rather than by def name (for some reason 
  [unknown to me] it just failed to delete the custom attribute from the rootNode when I used the CA Def name); but has
  no issues when I used the index number. 

- This script assumes that the outgoing/incoming skeleton share identical bone names.  However, it should be flexible
  enough to allow differnt outgoing/incoming bone names thru the matching of bones in the Load Envelopes dialog window.

- You're not an idiot.  I've done my best to idiot-proof this script with error-trapping. Attempting to catch all the
  ways this script could be abused (pressing buttons out of order, manually deleting bones or skin modifiers, repeatly
  pressing the "Save ENV" or "Load ENV" buttons, etc.).


Usage:
1.  With your scene open, run the script.

2.  Choose which file format you want to save your skin envelopes (default is binary).

3.  Press "Save ENV" --	This launchs a function that creates a custom attribute called "skinObj" on the rootNode 
			(i.e., the scene file itself) and it then parses the scene and collects a list of all skinned objects.
			While adding skinned objects to the rootNode.skinObjList array, it creates another custom
			attribute called "skinData" on the mesh objects to hold the current skin modifier data. You can
			access these custom attribute properties on the object by typing them in the Listener like any other
			node property (e.g., $.boneList and $.boneCount).  While processing each skinned object it finally
			saves the skin envelope file to the same directy where the scene resides.

4.  Once the skin envelopes have been saved.  You would press the "Remove Bones from Skin Modifiers" button.

5.  After step 4, you would then press "Delete Old Bones from Scene" button to remove/delete the old skeleton.

6.  Press "Merge Skeleton" -- This merges in the skeleton scene file to which you want to transfer the skin data.

7.  Press "Load ENV" -- This launches a function to load the skin envelopes back onto the mesh objects.

8.  Once everything has been fixed to your satisfaction, you should press the "Delete Objects CA" button.  This deletes
    the custom attributes (and its data) from each skinned object.

9.  Finally, after deleting the skinned objects' custom attribute this button will activate and you should delete the custom
    attributes from the scene rootNode.  This reduces file size since the data is no longer needed.

10. The "Reset" button simply resets the script buttons and progress bars.


Enjoy!  And please report any bugs or issues related to the script.

			


