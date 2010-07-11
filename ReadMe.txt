Hello,

Welcome to my Bitmap Scroller project. Once you have a look through the demo app
it should be relatively easy to incorporate this into your own project. Here is
a little info on how to get the demo up and running.

Building Without Ant

If you do not want to use ANT you must manually copy the build/bin-resources/images 
folder to your bin or bin-debug directory and compile the app like you normally 
would. The main class is called BitmapScrollerApp located in the src folder. This 
represents a demo class to show off how the BitmapScroller works.

You will also have to set up a few extra lines of code in the advanced compiler area 
of your project’s settings:

	-use-network=false (If you are not testing this on a localhost or server)

	-define=CONFIG::mobile,false (If you are compiling for desktop. For mobile 
	change this to true. This allows you to configure different logic for each 
	platform which I will talk about later).

	-static-link-runtime-shared-libraries=true (This is important on any project 
	that uses Flex 4 since it is set to false by default. This may not impact 
	this project but if you begin embedding assets it is key).


Building With  ANT

The build file is located in the root directory. It relies on a build.properties 
file to run. I provide a template file called build.template.properties which you 
can copy and rename to build.template. Once you do that open it up and lets change 
a few key properties.

You will need to set the following paths:

	FLEX_HOME - path to your Flex SDK. If you have FlashBuilder installed it 
	is located in the App’s dir under SDK 4.0.

	android.sdk - path to your Android SDK

	browser - On a PC you will want to use the path to the actual browser 
	such as C:/Program Files/Mozilla Firefox/firefox.exe. On a mac the name 
	of the browser will work such as Safari.

Once you set these paths you should be able to run the ANT Build. The default build 
is compile swf. After running it, the build will create a bin folder for you and 
compile the swf in there. From there you can launch the index.html however you want. 
There is an ANT target for local-run located in the compile-swf include build or use 
the IDE to launch the index file and trigger the debugger, which is what I normally do.
