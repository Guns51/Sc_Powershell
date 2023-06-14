Import-Module -Name ImportExcel


$fichier = Open-ExcelPackage -Path 'C:\Users\gunsa\Desktop\test3.xlsx'
$feuille = $fichier.Workbook.Worksheets['releve']

foreach ($t in $feuille){
    Write-Host("cc")
    Start-Sleep -Seconds 1
}
