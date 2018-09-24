Class Build.EthereumAdapter Extends %RegisteredObject
{

/// This method prompts the user for the name of the directory that contains the downloaded files 
/// and then builds the adapter.
ClassMethod Build()
{
    write !, "This is the setup method for the IRIS-Ethereum Adapter, which is meant for "
    write !, "use with the InterSystems IRIS Interoperability capabilities. "
        
    write !!, "To continue, please specify the full path of the directory that contains this "
    write !, "adapter. (This is the directory that contains the README.md and LICENSE files.)",!
    read "Your input: ",stagingroot
    if ($ZSTRIP(stagingroot,"<>W")="") {
        write !, "Not a valid directory. Quitting..."
        quit
    }
    
    if '##class(%File).DirectoryExists(stagingroot) {
        write !, "Directory not found. Quitting..."
        quit
    }
    
    set OK=..Run(stagingroot,1)
    
    if OK {
        write !!, "Setup successfully finished"
        write !, "See the README.md file for details."
    } else {
        write !!, "Setup was unsuccessful. Make sure that the directory you specified"
        write !, "contains the adapter classes."
    }
}
/// This method enables you to build the code with a minimum of output to the Terminal.
/// <var>stagingroot</var> is the name of the directory that contains the downloaded files. 
/// <var>interactive</var> controls whether this method displays output.
/// <methodname>Build</methodname> calls this method with interactive=1.
ClassMethod Run(stagingroot As %String = "", interactive As %Boolean = 0)
{

   //repeat this test here in case we go directly to this method
    if $ZSTRIP(stagingroot,"<>W")="" {
        if interactive {
            write !, "Not a valid directory... Quitting."
        }
        return 0
    }
    //load and compile classes 
    set dir = stagingroot_"/cls/" ;works on both Windows and Unix
    if '##class(%File).DirectoryExists(dir) {
        if interactive {
            write !!, "Looking for "_dir
            write !, "but it does not exist... Quitting."
        }
        return 0
    }
    if interactive {
        write !!, "Loading and compiling classes..."
    }
    do $system.OBJ.LoadDir(dir,"ck",,1)

    return 1
}

}