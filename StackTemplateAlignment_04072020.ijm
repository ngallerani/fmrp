/*
 * TEMPLATE MATCHING
 * 04072020
 * Version 1
 * Nick Gallerani
 * 
 * This macro combines images into a stack and then applies the Template Matching plugin developed by Qingzong Tseng and used in publications such as Tseng Q et al PNAS 2012
 * This macro requires the Template Matching plugin to be installed
 * For installation follow instructions here: https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin
 * Important: This did not work on my Windows 10 computer but runs perfectly on my MacBook
 * The issue is not the macro, it seems to be the plugin. Please follow the instructions for Windows installation to see if it is just my computer
 * 
 * HOW TO USE THIS MACRO
 * 1. Hit "Run" and you will be prompted to select the folder which contains images to be stacked
 * 		Images should be in a single channel TIF format	
 * 		All images in the folder will be stacked together into one stack
 * 		They should be formatted so that the "template" image has the lowest index
 * 		For example, say a folder contains: Image_01.tif, Image_02.tif, Image_03.tif
 * 		The order they will be stacked in is the same as I wrote it, and all images will be aligned to Image_01.tif
 * 2. The stacked image will be saved and reopened. A rectangle specifying the alignment ROI will be automatically created	
 * 		The alignment rectangle is 1/5 of the size of the image and automatically created with the top right corner at the center of the image
 * 		You do not have to use this rectangle, you can also specify your own rectangle around whatever landmark you wish to align the images to
 * 3. The macro will pause, you will have to run the alignment plugin manually. DO NOT HIT OK UNTIL THE PLUGIN RUNS OTHERWISE THERE WILL BE NO ALIGNMENT
 * 		Plugins -> Template Matching -> Align slices in stack...
 * 		If you don't see this you probably didn't install the plugin correctly.
 * 		Why do you have to do this? - Read the code. If you figure it out let me know
 * 4. 
 */

input = getDirectory("Choose Directory With Images To Be Stacked");
list = getFileList(input);
output = input + "/output/";
		check_folders = File.exists(output);
		if(check_folders==0){
		File.makeDirectory(output);}

makestack = 1; //these variables will be a dialog checkbox but for now are set to 1
alignstack = 1;
makecomposites = 1;



if(makestack==1){
setBatchMode(true);
//this block searches for the first TIF image in the file list and then defines the "template name" as that image's name, while ignoring any non-image files, such as folders or scripts that may be in the same input folder
definetemplate = 0;
for (i=0; i<list.length; i++) { 
	while(definetemplate == 0) {
		if (endsWith(list[i], ".tif")){ //this only opens up files that are in the proper TIF format
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
	if (endsWith(list[i], ".tif")){ //this only opens up files that are in the proper TIF format
		open(input+list[i]);	
	}
}
run("Images to Stack", "method=[Copy (center)] name=Stack use");
unalignedstackname = "Stack_" + ID + ".tif";
saveAs("tif", output + unalignedstackname);
run("Close All");
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
run("Set Measurements...", "center redirect=None decimal=3");
run("Select All");
run("Measure");
xCOM = getResult("XM")/scalefactor; 
yCOM = getResult("YM")/scalefactor; 
run("Clear Results");					
newW = 0.2*stackW;
newH = 0.2*stackH;
makeRectangle(xCOM, yCOM, newW, newH);
waitForUser("WORKAROUND: RUN TEMPLATE MATCHING PLUGIN THEN HIT OK ONCE PLUGIN IS FINISHED");
/*
&newW, &newH, etc should be the proper way to pass variables as arguments in ImageJ functions, but it isn't working
not sure why it doesn't work, but for now the work around is to simply run the plugin manually while the rest of the macro is paused

run("Align slices in stack...", "method=5 windowsizex=&newW windowsizey=&newH x0=&xCOM y0=&yCOM swindow=0 subpixel=false itpmethod=0 ref.slice=1 show=true");
*/

alignedstackname= "AlignedStack_" + ID + ".tif";
saveAs("tif", output + alignedstackname);
selectWindow("Results");
saveAs("Measurements", output + "Alignment_" + ID + ".csv");
run("Close");
selectWindow("Log");
saveAs("Text", output + "AlignmentLog_" +ID);
run("Close");
}

if (makecomposites==1){
	Dialog.create("Composite Images From Time Stack");
	Dialog.addNumber("Choose first slice #", 1);
	Dialog.addNumber("Choose second slice #", 2);
	Dialog.show();
	firstslice = Dialog.getNumber();
	secondslice = Dialog.getNumber();
	substack = newArray(firstslice,secondslice);
	run("Select None");
	run("Make Substack...", "  slices="+firstslice+","+secondslice);
    run("Make Composite", "display=Composite");
	run("Flatten");
	saveAs("tif", output + "Composite_" + firstslice + "_" + secondslice + "_" + alignedstackname);
	run("Close");
}


