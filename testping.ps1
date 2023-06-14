Import-Module -Name ImportExcel

[Environment]::SetEnvironmentVariable("CloseOrNot", "1", "machine")

function insertion_date_colonneA ()
{
    $conteur_colonne = 1
    $Jours = (Get-Date -Format dddd^dd/MM/yyyy).Replace("^"," ")
    while ($null -ne ($feuille.Cells['A'+($conteur_colonne)].Value)) # Temps que la cellule n'est pas vide
    {
        if ($feuille.Cells['A'+($conteur_colonne)].Value -eq $Jours) # Si la valeur de la cellule correpond à aujourd'hui
        {
            break
        }
        else    
        {
            $conteur_colonne++       
        }
    }
    if ($null -eq $feuille.Cells['A'+($conteur_colonne)].Value)  # Si la valeur de la cellule pour la date est vide    
    {
        $feuille.Cells['A'+($conteur_colonne)].Value = "$Jours"
        $feuille.Cells.AutoFitColumns()     
    }

    return $conteur_colonne  
}   

function resul_ping_fam ()
{
    $ping = Test-Connection 192.168.1.21 -Count 1 | Select-Object -Property Status
    if ($ping -match "Success")
    {
        return "*"
    }
    else 
    {
        return "^"
    }
}

function cellule_heure_final ()
{ 
    $conteur_ligne = 2
    $caratere = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $ping = resul_ping_fam
    while (!$null -eq ($feuille.Cells[$caratere[$conteur_ligne]+($conteur_colonne)].Value)) # Temps que la cellule n'est pas vide
    {
        $conteur_ligne++
        if ($conteur_ligne -ge 26)
        {
                break
        }      
    }
    if ($conteur_ligne -eq 26)
    {
        $conteur_ligne_deux = 0
        $lettre = "A"
        while (!$null -eq ($feuille.Cells[$lettre + ($caratere[$conteur_ligne_deux])+($conteur_colonne)].Value))
        {
            $conteur_ligne_deux++
            Start-Sleep -Seconds 0.3
            Write-Host ($lettre + ($caratere[$conteur_ligne_deux])+($conteur_colonne))
            if ($conteur_ligne_deux/26 -is [int])
            {
                $lettre = $caratere[($conteur_ligne_deux/26)]
                $conteur_ligne_deux = 0    
            }
        }
        
        $cellule = $lettre + $caratere[$conteur_ligne_deux]+($conteur_colonne)
        $feuille.Cells[$cellule].Value = (Get-Date -Format "HH:mm:ss") + $ping
    }
    else  
    {
        $cellule = ($caratere[$conteur_ligne]) + $conteur_colonne
        $feuille.Cells[$cellule].Value = (Get-Date -Format "HH:mm:ss") + $ping
    }
    
    $feuille.Cells.AutoFitColumns()
}

while ($true){  
    $a = 2

    if ($a -notmatch "Success"){
        $fichier = Open-ExcelPackage -Path 'C:\Users\gunsa\Desktop\test3.xlsx'
        $feuille = $fichier.Workbook.Worksheets['releve']
        $conteur_colonne = insertion_date_colonneA | Write-Output
        cellule_heure_final
        Close-ExcelPackage $fichier
        (New-Object Media.SoundPlayer "C:\WINDOWS\Media\Windows Background.wav").Play();
    }
    if (([Environment]::GetEnvironmentVariable("CloseOrNot", "machine")) -eq 0 ) 
    {
        break
    }
    Start-Sleep -Seconds 0.3

} 
