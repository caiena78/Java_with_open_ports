# Copyright (c) 2021  Chad Aiena <caiena78@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
param(
    $file
)



$jave_proc = Get-Process |  Where-Object {$_.Path -like '*java*'}
$connections= Get-NetTCPConnection
$htconn=@{}
$cnt=0

#Build a Hashtable with all the connection process id's
foreach ($con in $connections){    
    # skip over duplicates
   if ($htconn[[string] $con.OwningProcess] -eq $null ){        
        $htconn.Add([string] $con.OwningProcess, $cnt)        
   }
   $cnt++
}

# loop through all of these process that have Java in the path
ForEach ($proc in $jave_proc){
    #build and objec to hold the process
    $obj = "" | select-object computername,name,path,PID,localaddress,localport,remoteaddress,remoteport,state  
    #search for the process id in the has table to get the index
    $netidx=$htconn[[string] $proc.id]
    if ( $netidx -eq $null ){       
        #if the process id is not found skip to the next on 
        continue   
    }
    
    #Build the output object
    $obj.computername = hostname 
    $obj.name = $proc.name
    $obj.path = $proc.path
    $obj.PID = $proc.id
    $obj.localAddress = $connections[$netidx].localAddress
    $obj.localport= $connections[$netidx].localport
    $obj.remoteaddress = $connections[$netidx].remoteaddress
    $obj.remoteport = $connections[$netidx].remoteport
    $obj.state = $connections[$netidx].state
    
    #print the object to the console
    $obj

    $data = "{0},{1},{2},{3},{4},{5},{6},{7},{8}" -f $obj.computername, $obj.name, $obj.path, $obj.PID, $obj.localAddress, $obj.localport, $obj.remoteaddress,$obj.remoteport,$obj.state
    #write the data to a file
    add-content -path $file -value $data    

}
