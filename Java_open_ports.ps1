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
foreach ($con in $connections){    
   if ($htconn[[string] $con.OwningProcess] -eq $null ){        
        $htconn.Add([string] $con.OwningProcess, $cnt)        
   }
   $cnt++
}

ForEach ($proc in $jave_proc){
    $obj = "" | select-object computername,name,path,PID,localaddress,localport,remoteaddress,remoteport,state  
    $netidx=$htconn[[string] $proc.id]
    if ( $netidx -eq $null ){       
        continue   
    }
    
    $connections[$netidx]
    $obj.computername = hostname 
    $obj.name = $proc.name
    $obj.path = $proc.path
    $obj.PID = $proc.id
    $obj.localAddress = $connections[$netidx].localAddress
    $obj.localport= $connections[$netidx].localport
    $obj.remoteaddress = $connections[$netidx].remoteaddress
    $obj.remoteport = $connections[$netidx].remoteport
    $obj.state = $connections[$netidx].state
    
    $obj
    $data = "{0},{1},{2},{3},{4},{5},{6},{7},{8}" -f $obj.computername, $obj.name, $obj.path, $obj.PID, $obj.localAddress, $obj.localport, $obj.remoteaddress,$obj.remoteport,$obj.state
    add-content -path $file -value $data
    add-content 

}
