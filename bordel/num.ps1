 <#  
$a= 1  
switch ($a) {
    1 { 
        "ChampionSummary","PositionSummary","QueueSummary" | ForEach-Object {
            Write-Host $_
        "TOP","JUNGLE","MID","BOTTOM","SUPPORT" | ForEach-Object {
            if($_ -eq "MID"){return}
            Write-Host $_
        }
    }

     }
    Default {Write-Host "coucou"}
}   
   #>

   function Test-Function {
    $fishtank = 1..10
    
    $fishtank | %{
    
        if ($_ -eq 3)
        {
            #break      # <- abort loop
            continue  # <- skip just this iteration, but continue loop
            #return    # <- abort code, and continue in caller scope
            #exit      # <- abort code at caller scope 
        }

        "fishing fish $($_)"

    }
    'Done.'
}

Test-Function