# initialize the items variable with the
# contents of a directory
$processedDir = "C:\tmp\avaya\PROCESSED\"
$dump = "C:\tmp\avaya\DUMP\"
$backup = "C:\tmp\avaya\ARCHIVED\"


$checkrep = Test-Path "$processedDir\logs.csv"
 
     If ($checkrep -like "True") 
         { 
            Remove-Item "$processedDir\logs.csv"
         }
            
$i = 0

$items = Get-ChildItem -Path $dump
 
# enumerate the items array
foreach ($item in $items)
{ #100

    
        
      # if the item is NOT a directory, then process it.
      if ($item.Attributes -ne "Directory")
      {#102
            #Write-Host $item.Name
            $filename = $item.Name

            ##############################################################
            #check the file if existing or not
            $checkfile = Test-Path $backup$filename
            If ($checkfile -like "true") 
            {#104 

            #Remove-Item $dump$filename
            $a = "true"
            write-host "duplicate found for $filename from $backup$filename" 
            Remove-Item "$dump\$filename" | Where { ! $_.PSIsContainer }  
            write-host "file deleted from $dump$filename"                                 
            }
            else
            {
            write-host "uniqe file found! $filename"                       
            Copy-Item $dump$filename $backup$filename
            write-host "copy process success! $filename ($i)"
            $a = "false"   
            $i = $i + 1         
            }

            
            
            If ($a -like "false") #### if file exist dont do anything
            {#104
            ##############################################################
            #save the date inside of dump to variable
            #$date = gc $dump$filename -First 1
            ##############################################################
            
            ### remove the first line
            get-content $dump$filename |
            select -Skip 1 |
            set-content "$dump$filename-temp"
            ##############################################################            
            ### copy the processed dump file to processed folder
            move "$dump$filename-temp" "$processedDir$filename.0" -Force  
            ##############################################################
            
                                
            
            $raw = gc "$processedDir$filename.0"

            

            foreach ($activation in $raw)
            {#103

            $col1  = $activation.Substring(0,2)
            $col2  = $activation.Substring(2,2)
            $col3  = $activation.Substring(4,1)
            $col4  = $activation.Substring(5,2)
            $col5  = $activation.Substring(7,1)
            $col6  = $activation.Substring(8,1)
            $col7  = $activation.Substring(9,8)
            $col8  = $activation.Substring(17,14)
            $col9  = $activation.Substring(32,9)
            $col10 = $activation.Substring(42,6)
            $col11 = $activation.Substring(48,7)
            $col12 = $activation.Substring(55,2)
            $col13 = $activation.Substring(57,7)
            $col14 = $activation.Substring(64,9)
            $col15 = $activation.Substring(73,1)
            $col16 = $activation.Substring(74,17)
            $col17 = $activation.Substring(92,1)
            $col18 = $activation.Substring(93,1)
            $col19 = $activation.Substring(94,1)
            $col20 = $activation.Substring(95,9)
            $col21 = $activation.Substring(104,2)


            ##get the date from the filename
            foreach($dt in  $filename)
            {
            $yyyy  = $dt.Substring(13,2)                        
            $mo  = $dt.Substring(15,2)
            $dd  = $dt.Substring(17,2)                        
            $hh  = $dt.Substring(20,2)
            $mi = $dt.Substring(23,2)
            }

            $date = "$mo/$dd/$yyyy"


                if($col8 -like "*4171611*" ){ $sitename = "riyadh" }            
            elseif($col8 -like "*4171607*" ){ $sitename = "riyadh" }            
            elseif($col8 -like "*1700*" ){ $sitename = "riyadh" } 


            elseif($col8 -like "*4171614*" ){ $sitename = "taif"   }
            elseif($col8 -like "*4171610*" ){ $sitename = "taif"   }
            elseif($col8 -like "*29663*" ){ $sitename = "taif"   }


            elseif($col8 -like "*4171613*" ){ $sitename = "makkah" }
            elseif($col8 -like "*4171609*" ){ $sitename = "makkah" }
            elseif($col8 -like "*29662*" ){ $sitename = "makkah" }

            
            elseif($col8 -like "*4171612*" ){ $sitename = "jeddah" }
            elseif($col8 -like "*4171608*" ){ $sitename = "jeddah" }
            elseif($col8 -like "*29661*" ){ $sitename = "jeddah" }


            
            
            else {$sitename = "others"}

            if($col9 -like "5*") { $calltype = "mobile"}
            else { $calltype = "telephone"}


            
            add-content -path "$processedDir$filename.1" -value "$date,$hh,$mi,$dd,$mo,$yyyy,$sitename,$calltype,$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,$col11,$col12,$col13,$col14,$col15,$col16,$col17,$col18,$col19,$col20,$col21,$col22,$col23" 
            
            
                                   
            }#103 

            }#104 
            
      }#102

            

}#100


            if($i -gt 0)
            {
            #merge all csv file into rowdata.1
            cat "$processedDir\*.1" | sc "$processedDir\rowdata.2"    
            #load rowdata.1 content to varial $rowdata
            $rowdata      =           gc "$processedDir\rowdata.2"
            #define headers                        
            $colname = "creationstamp,hour,minute,duration-hour,duration-minute,duration-tenths-minute,condition-code,space1,dialed-number,calling-number,space2,terminating-dip-entity,space3,originating-sip-entity,space4,feature-flag,space5,bcc,ma-uui,resource-flag,space6,bandwith,carriage-return,line-feed"            
            #add headers to data1.csv                        

            add-content -path "$processedDir\logs.csv" -value $rowdata
            #Remove-Item "$processedDir\*.0" | Where { ! $_.PSIsContainer }
            #Remove-Item "$processedDir\*.1" | Where { ! $_.PSIsContainer }
            #Remove-Item "$processedDir\*.2" | Where { ! $_.PSIsContainer } 
            
            write-host "dump log processing done! $filename"           
            

            $csvfilename = (Get-Date).AddDays(0).ToString('yyyyMMdd-hh_mm')

            #archived logs.csv to CSV folder
            Copy-Item  "$processedDir\logs.csv" "C:\tmp\avaya\CSV\$csvfilename.csv" -Force
            write-host "logs archived! filename $csvfilename.csv item#"


            
            #clean directories

            #Remove-Item "$processedDir\*.*" | Where { ! $_.PSIsContainer } #i cannot delete need to be process by import bat
            Remove-Item "$dump\*" | Where { ! $_.PSIsContainer }
            
            

            }#


