/*
 * STACK TEMPLATE MATCHING
 * Version 1: 04072020
 * Version 2: 04092020
 * Author: Nick Gallerani
 * 
 * OVERVIEW:
 * This macro combines images into a stack 
 * and then applies to the stack the Template Matching plugin developed by Qingzong Tseng and used in publications such as Tseng Q et al PNAS 2012
 * and then creates color images from any two slices within both the unaligned and aligned stacks
 * All images are saved using the name of the first image in the stack-aka the "template"
 * 
 * IMPORTANT NOTES:
 * This macro requires the Template Matching plugin to be installed
 * For installation follow instructions here: https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin
 * This did not work on my Windows 10 computer but runs perfectly on my MacBook
 * I think the issue is the plugin itself, but the plugin should in theory work on Windows if you follow the instructions. 
 * I didn't spend time troubleshooting the issue, I just moved to my MacBook. Please let me know if it works on your Windows system
 * 
 * INSTRUCTIONS
 * 1. Make sure your images are formatted properly
 * 		My images were 16 bit single channel greyscale TIF images
 * 		Images must have .tif extension, bit depth is probably not an issue but I haven't tested anything else
 * 		All the images that you want to be stacked should be in one folder together
 * 		Its okay to have other file types in this folder, they won't be stacked unless they are .tif format
 * 		The filenames should be formatted so that the "template" image has the lowest index
 * 		For example, say a folder contains: Image_01.tif, Image_02.tif, Image_03.tif
 * 		The order they will be stacked in is the same as I wrote it, and all images will be aligned to Image_01.tif
 * 2. Hit "Run" and a dialog box appears
 * 		Explanation of the options: (Note that its best to leave the checkboxes checked-I haven't tested various combos of unchecking and do not plan to do this, but I know some will probably break the code in some way)
 * 		Stack Images-Uncheck if you are starting from an existing stack
 * 		Align Stack-This really shouldn't be unchecked because thats the main point of this macro. But you could use the macro to just stack images or just make composites, in theory. I don't know that it runs properly if this is unchecked though
 * 		Make Composite On Aligned/Unaligned-This creates and saves a 2 channel composite image from any 2 slices within either your unaligned or aligned stack images. This is mainly used for quality control and for use in a figure/demo purposes.
 * 		First/Second Image #-Specify the images within the stacks to make composites from.
 * 			For example, say you have a stack with 10 images, and you wanted to compare the alignment of image 2 with image 8
 * 			You would change First # to 2, and Second # to 8
 * 			This would generate a flattened, composite color image where the red channel is image 2, and the green channel is image 8, while yellow would show the overlap between channels
 * 3. Hit "OK" and then select the directory that contains your images that you want to stack		
 * 		or, if you have an existing stack, select that stack
 * 4. Hit "OK" and wait for the macro to finish		
 * 		Assuming all options were checked you should end up with an "output" folder containing 6 files:
 * 		Alignment_<TemplateName>.csv
 * 		Stack_<TemplateName>.tif
 * 		AlignedStack_<TemplateName>.tif
 * 		Composite_<1stSlice>_<2ndSlice>_<Stack>_<TemplateName>.tif
 * 		Composite_<1stSlice>_<2ndSlice>_<AlignedStack>_<TemplateName>.tif
 * 		AlignmentLog_<TemplateName>.txt (this doesn't really contain much useful info at the moment)
 *  
 *  NOTE ABOUT ALIGNMENT:
 *  In the original plugin the user manually specified the landmark to be aligned by manually drawing a rectangular selection around this landmark
 *  In this version, the rectangle is automatically created, each dimension is 1/5 the size of the image itself, and is drawn with the top left corner at the center of the image
 *  This completely automates the process but may not necessarily provide the best landmark
 *  See the code itself for instructions on how to change it to manual input-should be roughly line 169 as of Version 2 
 *  
 *  
 */



Dialog.create("Stack->Align->Composite");
	Dialog.addCheckbox("Stack Images", true);
	Dialog.addCheckbox("Align Stack", true);
	Dialog.addCheckbox("Make Composite On Unaligned", true);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Make Composite On Aligned", true);
	Dialog.addMessage("Specify which images in the stack to make composites from")'
	Dialog.addNumber("First image #: ", 1);
	Dialog.addToSameRow();
	Dialog.addNumber("Second image #: ", 2);
	Dialog.show();
makestack = Dialog.getCheckbox(); 
alignstack = Dialog.getCheckbox();
makecomposites = Dialog.getCheckbox();
makecomposites2 = Dialog.getCheckbox();
firstslice = Dialog.getNumber();
secondslice = Dialog.getNumber();



if(makestack==1){


input = getDirectory("Choose Directory With Images To Be Stacked");
list = getFileList(input);
output = input + "/output/";
		check_folders = File.exists(output);
		if(check_folders==0){
		File.makeDirectory(output);}
	
setBatchMode(true);
definetemplate = 0;
for (i=0; i<list.length; i++) { 
	while(definetemplate == 0) {
		if (endsWith(list[i], ".tif")){ 
			open(input+list[i]);
				templateName = getTitle(); 
				extIndex = indexOf(templateName, ".tif"); 
				ID = substring(templateName, 0, extIndex);
				print("Template Name: " + ID);
				definetemplate=1;	
			close();	
		}
	}				
}
	
for (i=0; i<list.length; i++) { 
	if (endsWith(list[i], ".tif")){ 
		open(input+list[i]);	
	}
}
run("Images to Stack", "method=[Copy (center)] name=Stack use");
unalignedstackname = "Stack_" + ID + ".tif";
saveAs("tif", output + unalignedstackname);

if (makecomposites==1){
	img = getTitle();
	compflat(img);
	saveAs("tif", output + "Composite_" + firstslice + "_" + secondslice + "_" + unalignedstackname);
}



run("Close All");
}else{
	//if the stacked image already exists, you can run the macro by specifying the path
	  existingstackpath = File.openDialog("Select The Stacked Image");
	  open(existingstackpath);

      input = File.getParent(existingstackpath);
	  list = getFileList(input);
      output = input + "/output/";
		check_folders = File.exists(output);
		if(check_folders==0){
		File.makeDirectory(output);}

	  
	  templateName = getTitle(); 
	  extIndex = indexOf(templateName, ".tif"); 
	  ID = substring(templateName, 0, extIndex);
	  print("Image Already Stacked");
	  print("Template Name: " + ID);
}


if (alignstack==1){
setBatchMode(false);

open(output + unalignedstackname);
print("Unaligned Stack: " + unalignedstackname);

//automatically make a rectangle at the center of the image
getPixelSize (unit, pixelWidth, pixelHeight);
scalefactor=pixelWidth;

stackW = getWidth();
stackH = getHeight();
run("Set Measurements...", "center redirect=None decimal=1");
run("Select All");
run("Measure");
xCOM = floor(getResult("XM")/scalefactor); 
yCOM = floor(getResult("YM")/scalefactor); 
run("Clear Results");	
selectWindow("Results");
run("Close");				
newW = floor(0.2*stackW);
newH = floor(0.2*stackH);
makeRectangle(xCOM, yCOM, newW, newH);

//if you want to manually define your landmark, I would insert a line with a wait for user command, and comment out the line right below this one that calls the plugin, and then manually run the plugin at this step.
run("Align slices in stack...", "method=5 windowsizex="+newW+" windowsizey="+newH+" x0="+xCOM+" y0="+yCOM+" swindow=0 subpixel=false itpmethod=0 ref.slice=1 show=true");

alignedstackname= "AlignedStack_" + ID + ".tif";
saveAs("tif", output + alignedstackname);
selectWindow("Results");
saveAs("Measurements", output + "Alignment_" + ID + ".csv");
run("Close");
selectWindow("Log");
saveAs("Text", output + "AlignmentLog_" +ID);
run("Close");
}

if (makecomposites2==1){
	img = getTitle();
	compflat(img);
	saveAs("tif", output + "Composite_" + firstslice + "_" + secondslice + "_" + alignedstackname);
	run("Close");
	selectWindow(img);
	run("Close");
}

function compflat(img){
	substack = newArray(firstslice,secondslice);
	run("Select None");
	run("Make Substack...", "  slices="+firstslice+","+secondslice);
    run("Make Composite", "display=Composite");
	run("Flatten");
}


