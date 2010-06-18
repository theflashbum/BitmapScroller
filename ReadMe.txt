Hello,

Welcome to my Flash TDD Project Template. I will be adding instructions here 
on how to use this file but for now just copy build.template.properties to 
build.properties, point FLEX_HOME to where you keep your Flex 4.0 SDK lives on 
your computer, run the build file then sit back and enjoy the show.

What is going on?

This build will run the unit tests.

If the test fails it will attempt to open up the report in the web browser you
specify in the build.properties file (may only work on the mac right now).

If the test passes you will not see the report. A bin folder will be
created, based on the files in build/bin-resrouces (where you keep external files
for your project) and build/html-template (the html template file in it's property
file).

Once the bin folder is setup, the browser will attempt to launch the index.html
file and let you preview your swf.