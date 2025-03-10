# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='template'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='1.0' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# toolVersion will automatically be written into README.md - for this to work leave "toolVersion" in the README unaltered.

# !!!!
# You can test the container build locally by running `bash build.sh -ds`
# !!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh
###########################################################################################################################################
# IF POSSIBLE, PLEASE DOCUMENT EACH ARGUMENT PROVIDED TO NEURODOCKER. USE THE `# your comment` NOTATION THAT ALLOWS MID-COMMAND COMMENTS
# NOTE 1: THE QUOTES THAT ENCLOSE EACH COMMENT MUST BE BACKQUOTES (`). OTHER QUOTES WON'T WORK!
# NOTE 2: THE BACKSLASH (\) AT THE END OF EACH LINE MUST FOLLOW THE COMMENT. A BACKSLASH BEFORE THE COMMENT WON'T WORK!
# NOTE 3: COMMENT LINES, I.E. LINES THAT START WITH #, CANNOT BE INCLUDED IN THE MIDDLE OF THE neurodocker generate COMMAND. INSTEAD,
#         USE AN EMPTY LINE AND PUT YOUR COMMENT AT THE END USING THIS FORMAT: `# your comment goes here` \ 
##########################################################################################################################################
neurodocker generate ${neurodocker_buildMode} \
   --base-image neurodebian:sid-non-free                `# RECOMMENDED TO KEEP AS IS: neurodebian makes it easy to install neuroimaging software, recommended as default` \
   --env DEBIAN_FRONTEND=noninteractive                 `# RECOMMENDED TO KEEP AS IS: this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# RECOMMENDED TO KEEP AS IS: desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# RECOMMENDED TO KEEP AS IS: define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# RECOMMENDED TO KEEP AS IS: make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                   `# MANDATORY: create folders for singularity bind points` \
   --install wget git curl ca-certificates unzip        `# RECOMMENDED: install system packages` \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin `# MANDATORY: add your tool executables to PATH` \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ `# MANDATORY: define which directory's binaries should be exposed to module system (alternative: DEPLOY_BINS -> only exposes binaries in the list)` \
   --copy README.md /README.md                          `# MANDATORY: include readme file in container` \
   --copy license.txt /license.txt                          `# MANDATORY: include license file in container` \
   --copy * /neurodesk/                              `# MANDATORY: copy test scripts to /neurodesk folder - build.sh will be included as well, which is a good idea` \
   --run="chmod +x /neurodesk/*.sh"                     `# MANDATORY: allow execution of all shell scripts in /neurodesk inside the container` \
  > ${imageName}.${neurodocker_buildExt}                `# THIS IS THE LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
