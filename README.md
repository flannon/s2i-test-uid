
## Make a builder image to use with the OpenShift docker build strategy     

### Description

The build-rpm image provides an environment for building rpms when provided with the environment variables SRC_RPM and SRC_RPM_LOCATION.

### Usage

####	Make the builder image

    oc new-build https://github.com/flannon/s2i-builder-rpm

	When the build finishes it will create the image stream

    oc get is

  View the logs to monitor the ubild processes

    oc logs -f bc/s2i-builder-rpm

	To iterate on the build image run oc start build against the build config

    oc start-build s2i-builder-rpm

#### Build the application

    oc new-app <is-name> -env=<env_vars>

  To build the rpm you need to provide values for SRC_RPM and SRC_RPM_LOCATION, which define the location of the src rpm to build.

  For example to build the most recent verison of git from the Fedora source tree to run on centos you can do the following,

    oc new-app s2i-builder-rpm  --env=SRC_RPM=git-2.14.2-2.fc27.src.rpm --env=SRC_RPM_LOCATION=https://dl.fedoraproject.org/pub/fedora/linux/updates/testing/27/SRPMS/g/git-2.14.2-2.fc27.src.rpm

  To view the  application's progress watch the deployment configuration log

    oc get dc
    oc logs -f dc/builder-rpm


### Files and Directories  
| File                   | Required? | Description                                                  |
|------------------------|-----------|--------------------------------------------------------------|
| Dockerfile             | Yes       | Defines the base builder image                               |
| s2i/bin/assemble       | Yes       | Script that builds the application                           |
| s2i/bin/usage          | No        | Script that prints the usage of the builder                  |
| s2i/bin/run            | Yes       | Script that runs the application                             |
| s2i/bin/save-artifacts | No        | Script for incremental builds that saves the built artifacts |
| test/run               | No        | Test script for the builder image                            |
| test/test-app          | Yes       | Test application source code                                 |

#### Dockerfile
Create a *Dockerfile* that installs all of the necessary tools and libraries that are needed to build and run our application.  This file will also handle copying the s2i scripts into the created image.

#### S2I scripts

##### assemble
Create an *assemble* script that will build our application, e.g.:
- build python modules
- bundle install ruby gems
- setup application specific configuration

The script can also specify a way to restore any saved artifacts from the previous image.   

##### run
Create a *run* script that will start the application. 

##### save-artifacts (optional)
Create a *save-artifacts* script which allows a new build to reuse content from a previous version of the application image.

##### usage (optional) 
Create a *usage* script that will print out instructions on how to use the image.

##### Make the scripts executable 
Make sure that all of the scripts are executable by running *chmod +x s2i/bin/**

#### Create the builder image
The following command will create a builder image named s2i-builder-rpm based on the Dockerfile that was created previously.
```
docker build -t s2i-builder-rpm .
```
The builder image can also be created by using the *make* command since a *Makefile* is included.

Once the image has finished building, the command *s2i usage s2i-builder-rpm* will print out the help info that was defined in the *usage* script.

#### Testing the builder image
The builder image can be tested using the following commands:
```
docker build -t s2i-builder-rpm-candidate .
IMAGE_NAME=s2i-builder-rpm-candidate test/run
```
The builder image can also be tested by using the *make test* command since a *Makefile* is included.

#### Creating the application image
The application image combines the builder image with your applications source code, which is served using whatever application is installed via the *Dockerfile*, compiled using the *assemble* script, and run using the *run* script.
The following command will create the application image:
```
s2i build test/test-app s2i-builder-rpm s2i-builder-rpm-app
---> Building and installing application from source...
```
Using the logic defined in the *assemble* script, s2i will now create an application image using the builder image as a base and including the source code from the test/test-app directory. 

#### Running the application image
Running the application image is as simple as invoking the docker run command:
```
docker run -d -p 8080:8080 s2i-builder-rpm-app
```
The application, which consists of a simple static web page, should now be accessible at  [http://localhost:8080](http://localhost:8080).

#### Using the saved artifacts script
Rebuilding the application using the saved artifacts can be accomplished using the following command:
```
s2i build --incremental=true test/test-app nginx-centos7 nginx-app
---> Restoring build artifacts...
---> Building and installing application from source...
```
This will run the *save-artifacts* script which includes the custom code to backup the currently running application source, rebuild the application image, and then re-deploy the previously saved source using the *assemble* script.
