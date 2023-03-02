var perform=true;       

// Set up the dialog box to allow user to input parameters for simulation 

Dialog.create("3D Synthetic Surfaces: Create random surface for simulation")
		
		Dialog.addSlider("             Length:", 1,200,100 );
		Dialog.addSlider("             Number of slices:", 1,100,100 );
		Dialog.addChoice("Image size:", newArray("256","512", "1024"));
		Dialog.addMessage("Example save location: C:\\Users\\HMXIF Remote\\Harry\\Data (or one slash may be used)");
		Dialog.addString("Enter: ", "save location");
		
		
		Dialog.addMessage("Note below the following parameters:");
		Dialog.addMessage("Thickness: depth of material around the rough inside faces.");
		Dialog.addMessage("Wavelength: distance between adjacent random changes in surface height.");
		Dialog.addMessage("Amplitude: maximum such deviation between adjacent surface heights (along one slice).");
		
		Dialog.addSlider("Thickness Min:", 1, 50, 0.5);
		Dialog.addToSameRow(); // The next item is appended next to the tick box
		Dialog.addSlider("Thickness Max:", 1, 50, 0.5); 
		Dialog.addToSameRow(); // The next item is appended next to the tick box
		Dialog.addSlider("Thickness Interval:", 1, 10, 0.5);
		
		Dialog.addSlider("Wavelength Min:", 1, 50, 0.5);
		Dialog.addToSameRow(); // The next item is appended next to the tick box
		Dialog.addSlider("Wavelength Max:", 1, 50, 0.5); 
		Dialog.addToSameRow(); // The next item is appended next to the tick box
		Dialog.addSlider("Wavelength Interval:", 1, 10, 0.5);
		
		Dialog.addSlider("Amplitude Min:", 0, 20, 1);
		Dialog.addToSameRow(); // The next item is appended next to the tick box
		Dialog.addSlider("Amplitude Max:", 1, 20, 1); 
		Dialog.addToSameRow(); // The next item is appended next to the tick box
		Dialog.addSlider("Amplitude Interval:", 1, 10, 0.1);
		
		Dialog.addSlider("Number of Repeats:", 1, 10, 1);
		
		Dialog.addMessage("Please note:");
		Dialog.addMessage("Unit is in pixels. The structure created is not necessarely centered in the canvas.");
		Dialog.addMessage("For correlating with virtual CT data, please resize image when created");

		Dialog.addCheckbox("Suppress non-surface elements (clean any anomolies from the surface generation)", false); // Returns 1 if ticked or 0 if not ticked
		Dialog.show();

// Recalling all values inputted by user as variables to be used during surface generation / saving

		L = Dialog.getNumber();
		N = Dialog.getNumber();
		siz = Dialog.getChoice();
		name= "image name";
		save_location = Dialog.getString();
		
		thick_min = Dialog.getNumber();
	    thick_max = Dialog.getNumber();
	    thick_interval = Dialog.getNumber();
	    
	    wave_min = Dialog.getNumber();
	    wave_max = Dialog.getNumber();
	    wave_interval = Dialog.getNumber();
	    
	    amp_min = Dialog.getNumber();
	    amp_max = Dialog.getNumber();
	    amp_interval = Dialog.getNumber();
	    
		repeats = Dialog.getNumber();
		cleaning = Dialog.getCheckbox();

// Print inputter parameters for user to recall what simulations are being run

print("Parameters:")
print("Length:", L);
print("Number of slices: ", N);
print("Length of square: ", siz);
print("Save Location: ", save_location);
print("Minimum thickness: ", thick_min, "Maximum thickness: ", thick_max, "Interval of thickness:", thick_interval);
print("Wavelength minimum: ", wave_min, "wavelength maximum: ", wave_max, "wavelength interval: ", wave_interval);
print("Amplitude minimum: ", amp_min, "amplitude maximum: ", amp_max, "amplitude interval:", amp_interval);
print("Number of repeats: ", repeats)
print("Clearning: ", cleaning)

repeat=0;
should_continue = "True";

// Validating Data

if(thick_min>thick_max){
	print("ERROR: Maximum thickness must be greater than (or equal to) minimum thickess");
}
if(wave_min>wave_max){
	print("ERROR: Maximum wavelength must be greater than (or equal to) minimum wavelength");
}
if(amp_min>amp_max){
	print("ERROR: Maximum amplitude must be greater than (or equal to) minimum amplitude"); 
}

// Run generation of surfaces in loops as defined by user

while(should_continue == "True"){ // Loops is exited if simulation is completed
	for (thickness=thick_min; thickness<=thick_max; thickness+=thick_interval) { // Generates surfaces between the bounds inputted by the user
		for (F=wave_min; F<=wave_max; F+=wave_interval) {
			for (A=amp_min; A<=amp_max; A+=amp_interval) {
				newImage(name, "8-bit black", siz, siz, N);
				n=nSlices;
				// Initiation

				for (u=1; u<n+1; u++)
					{
					setSlice(u);
					x0=((0.5*siz)-(0.5*L)) ;                                                            // x coord of starting point
					y0=300;														    	// y coord of starting point
					
				// First random surface generated starting from point (x0,y0) with frequence F and Amplitude A
					for (j1=x0; j1<=(x0+L);j1+=F) { 
						x1=j1;
						r1=x0+(A*(random()));
						makePoint(x1,r1);
					//	wait(10);
						roiManager("Add");
					}
						
							// last point coordinate used as starting point for the second random surface generated
								nRa = roiManager("count");
								nR1=nRa-1;
								roiManager("Select", nR1);    									 
								getSelectionCoordinates(x, y); 
								x1 = x[0]; 
								y1 = y[0]; 
								a1 = y1+L ;       	 
					 
				// Second random surface generated starting from point (x1,y1) with frequence F and Amplitude A
				for (j2=y1; j2<=a1;j2+=F) { 
					y2=j2-A;
					r2=-A+x1+(A*(1+random()));
					makePoint(r2,y2);
				//	wait(10);
					roiManager("Add");
					} 
							// last point coordinate used as starting point for the third random surface generated
								nRb = roiManager("count"); 
								nR2=nRb-2;  
								roiManager("Select", nR2);    									 
								getSelectionCoordinates(x, y); 
								x2 = x[0]; 
								y2 = y[0]; 
								a2 = y2-L ; 
						
				// Third random surface generated starting from point (x2,y2) with frequence F and Amplitude A
				for (j3=y2;j3>=a2;j3-=F) { 
					x3=j3; 
					r3=x2+(A*(1+random()));
					makePoint(x3,r3);
//wait(10);
					roiManager("Add");
					}  
						
				// last point coordinate used as starting point for the third random surface generated
								nRc = roiManager("count");
								nR3=nRc-1;
								roiManager("Select", nR3);    									 
								getSelectionCoordinates(x, y); 
								x3 = x[0]; 
								y3 = y[0]; 
								a3 = y3-L ;
					
					// Fourth random surface generated starting from point (x3,y3) with frequence F and Amplitude A
						
				for (j4=y3; j4>=a3;j4-=F) { 
					y4=j4;
					r4=-A+x3+(A*(1+random()));
					makePoint(r4,y4);
				//	wait(10);
					roiManager("Add");
					} 
					
				// Printing the Full surface
					
				nRd = roiManager("count");
				nR4=nRd-1;
					 
					 
				for (k=0; k<nR4;k++) { 
						
					roiManager("Select", k);
					getSelectionCoordinates(x, y); 
					xp = x[0]; 
					yp = y[0]; 
					v=k+1;
					roiManager("Select",v);
					getSelectionCoordinates(x,y); 
					xq = x[0]; 
					yq = y[0];  
					makeLine(xp,yp,xq,yq); 
					setForegroundColor(255, 255, 255);
					run("Draw", "slice");
				//	wait(10);
					}
					
				//connecting the last point
					
					 	
					roiManager("Select", nR4);
					getSelectionCoordinates(x, y); 
					x1f = x[0]; 
					y1f = y[0]; 
						 
					roiManager("Select",0);
					getSelectionCoordinates(x,y);
					x2f = x[0];
					y2f = y[0];
						 
					makeLine(x1f,y1f,x2f,y2f); 
					setForegroundColor(255, 255, 255);
					run("Draw", "slice");
				//	wait(10);
						
						
				if (isOpen("ROI Manager")) { 
					    selectWindow("ROI Manager");
					    run("Close"); // wait(10);
					    } 
					
				} 
					 
					// bounding box
					
					
				run("Colors...", "foreground=white background=black selection=yellow");
					
				for (n=1; n<=nSlices;n++) {  //Fills all rough surfaces with substance (to be later inverted)
					setSlice(n);
		
					doWand((x0+(L/2)), (x0+(L/2)), 0, "Legacy");
					run("Fill", "slice");
					}
					
					
				doWand(x0+(L/2), x0+(L/2));
				run("Fit Rectangle");
				run("Enlarge...", "enlarge=thickness"); //Forms a layer of a user inputted thickness around the rough surface
				run("Fit Rectangle");
				setBackgroundColor(0, 0, 0);
				run("Clear Outside", "stack"); // Deletes any particles generated outside of the bounds of the cube
       			run("Invert", "stack");
       			repeat_number = repeat + 1;
				file_name = save_location+"\\A="+A+", I="+F+", T="+thickness+"-"+repeat_number+"(Not Cleaned).tif";
				saveAs("Tiff", file_name); //Initially saves the images as .tif
				print(file_name, "saved");
				
				
			    file_title = getTitle(); //Retrieves the location of the tif to open in 3D Viewer
				run("3D Viewer");
				call("ij3d.ImageJ3DViewer.add", file_title, "None", file_title, "50", "true", "true", "true", "1", "2"); //Opens tif as surfaces in ImageJ 3D Viewer
				call("ij3d.ImageJ3DViewer.select", file_title);
				file_type = ".stl";
				full_title = save_location+"\\A="+A+", I="+F+", T="+thickness+"-"+repeat_number+"(Not Cleaned)"+file_type; //Forms full .stl file name and saves as a ASCII .stl File (this can be changed to binary)
				print(full_title, "saved");
				call("ij3d.ImageJ3DViewer.exportContent", "STL ASCII", full_title); // Also saves file as a .stl
				call("ij3d.ImageJ3DViewer.close");
			
				
				if (cleaning == 1) { // Re-saves both the .tif and .stl files if cleaning is selected (so a total of 4 files are saved per parameter set)
					for (n=1; n<=nSlices;n++) {  //Fills all rough surfaces with substance (to be later inverted)
					setSlice(n);
					
					// Cleaning process below using 'magic wand' selection at center of the square (hence the innermost surface is selected and the square is generated around this 'inner surface')
					doWand(siz/2, siz/2, 0, "Legacy");
					setBackgroundColor(0, 0, 0);
					run("Clear Outside", "slice");
					setForegroundColor(255, 255, 255);
					run("Fill", "slice");
					setTool("rectangle");
					run("Fit Rectangle");
					run("Enlarge...", "enlarge=thickness"); // Again, the thickness parameter is used as the depth of the material around the generated surface
					run("Fit Rectangle");
					run("Invert", "slice");
					}
				
				file_name = save_location+"\\A="+A+", I="+F+", T="+thickness+"-"+repeat_number+"(Cleaned).tif";
				saveAs("Tiff", file_name); //Initially saves the images as .tif
				print(file_name, "saved");
				file_title = getTitle(); //Retrieves the location of the tif to open in 3D Viewer
				//	print(file_title);
				run("3D Viewer");
				call("ij3d.ImageJ3DViewer.add", file_title, "None", file_title, "50", "true", "true", "true", "1", "2"); //Opens tif as surfaces in ImageJ 3D Viewer
				call("ij3d.ImageJ3DViewer.select", file_title);
				file_type = ".stl";
				full_title = save_location+"\\A="+A+", I="+F+", T="+thickness+"-"+repeat_number+"(Cleaned)"+file_type; //Forms full .stl file name and saves as a ASCII .stl File (this can be changed to binary)
				print(full_title, "saved");
				call("ij3d.ImageJ3DViewer.exportContent", "STL ASCII", full_title);
				call("ij3d.ImageJ3DViewer.close");
					}
				}
			}
		 }
    repeat += 1;
    if (repeat>=repeats) {
    	should_continue = "False";
    	}
    } //Macro loop is exited to ensure values are not repeated
