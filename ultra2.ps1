Import-Module -Name ImportExcel

Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@

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

function testAPPS ()
{
    $resultTestApp = ""
    try 
    {
        $resultTestLOL = Get-Process -Name 'LeagueClient' -ErrorAction Stop -InformationAction SilentlyContinue
        $resultTestApp += "'LOL'"  
    }
    catch 
    {   }
    try 
    {
        $resulGetDIS = Get-Process -Name 'Discord' -ErrorAction Stop -InformationAction SilentlyContinue
        $resultTestApp += "'DIS'"
    }
    catch 
    {   }
    return $resultTestApp
}

function cellule_heure_final ()
{ 
    $conteur_ligne = 2
    $caratere = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $apptests = testAPPS
    while (!$null -eq ($feuille.Cells[$caratere[$conteur_ligne]+($conteur_colonne)].Value)) # Temps que la cellule n'est pas vide
    {
        $conteur_ligne++
        if ($conteur_ligne -eq 26) 
        {
                break
        }      
    }
    if ($conteur_ligne -eq 26)
    {
        $conteur_ligne_deux = 0
        while (!$null -eq ($feuille.Cells["A" + ($caratere[$conteur_ligne_deux])+($conteur_colonne)].Value))
        {
            
            $conteur_ligne_deux++
        }
        
        $cellule = "A" + $caratere[$conteur_ligne_deux]+($conteur_colonne)
        $feuille.Cells[$cellule].Value = (Get-Date -Format "HH:mm:ss") + " " + $apptests + " Inac : " + ([PInvoke.Win32.UserInput]::IdleTime).Seconds
    }
    else  
    {
        $cellule = ($caratere[$conteur_ligne]) + $conteur_colonne
        $feuille.Cells[$cellule].Value = (Get-Date -Format "HH:mm:ss") + " " + $apptests + " Inac : "+ ([PInvoke.Win32.UserInput]::IdleTime).Seconds
    }
    
    $feuille.Cells.AutoFitColumns()
}


while ($true){  
    $resul_ping = Test-Connection 8.8.8.8 -Count 1 | Select-Object -Property Status 
    
    if ($resul_ping -notmatch "Success"){
        $fichier = Open-ExcelPackage -Path 'C:\Users\gunsa\Desktop\test2.xlsx'
        $feuille = $fichier.Workbook.Worksheets['releve']
        $conteur_colonne = insertion_date_colonneA | Write-Output
        cellule_heure_final
        Close-ExcelPackage $fichier
        #(New-Object Media.SoundPlayer "C:\WINDOWS\Media\Windows Background.wav").Play();
    }
    Start-Sleep -Seconds 1
    $conteur ++
    Write-Host $conteur
} 
