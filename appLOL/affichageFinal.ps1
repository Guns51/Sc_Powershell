$display ={
param($tableauStats)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Créer une fenêtre Windows Forms
$form = New-Object Windows.Forms.Form
$form.Text = "Exemple de TreeView"
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
# Créer un contrôle TreeView
$treeView = New-Object Windows.Forms.TreeView
$treeView.Dock = [System.Windows.Forms.DockStyle]::Fill
############################
$treeView.ForeColor = [System.Drawing.Color]::DarkGray
$treeView.BackColor = [System.Drawing.Color]::Black
$treeView.Font = New-Object Drawing.Font("Bahnschrift Light", 11, [Drawing.FontStyle]::Regular)
$treeView.HideSelection = $true
$treeView.ShowLines = $true
$treeView.ShowRootLines = $false
$treeView.ShowRootLines = $true
$treeView.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$treeView.ItemHeight = 20
$treeView.FullRowSelect = $true
$treeView.Indent = 50
$treeView.LineColor = [System.Drawing.Color]::Cyan
$treeView.Add_AfterSelect({
    $treeView.SelectedNode = $null
})
$treeView.Add_NodeMouseClick({
    $node = $_.Node
    if (-not $node.IsExpanded) {
        $node.Expand()
    }else{$node.Collapse()}
})

# Ajouter des nœuds au TreeView
$rootNode = $treeView.Nodes.Add("Game")
$rootNode.BackColor = [System.Drawing.Color]::DarkBlue
$rootNode.ForeColor = [System.Drawing.Color]::LightCyan
$tableauStats.keys | %{
    $teamTree = $_
    $childNode = $rootNode.Nodes.Add("$_") #teams
    "TOP","JUNGLE","MID","BOTTOM","SUPPORT" | % {
        $positionTree = $_
        $childNode1 = $childNode.Nodes.Add("$_")
        "ChampionSummary","PositionSummary","QueueSummary" | % {
            $summaryTree = $_
            $childNode2 = $childNode1.Nodes.Add("$_")
            "winrate","nbPlayed","nbWIN" | % {
                $typeStatTree = $_
                $childNode3 = $childNode2.Nodes.Add("$_")
                $childNode4 = $childNode3.Nodes.Add($tableauStats."$($teamTree)".$($positionTree).$($summaryTree).$($typeStatTree))
                if($typeStatTree -eq "winrate"){
                    $childNode3.Expand()
                    $pourcentage = ($childNode4 |Select-String -Pattern '\d+' -AllMatches).Matches.Value
                    Write-Host $pourcentage
                    $childNode4.NodeFont = New-Object Drawing.Font("Bahnschrift Light",13,[Drawing.FontStyle]::Bold)
                    if($pourcentage -lt 50 )
                    {
                        $childNode4.ForeColor = [System.Drawing.Color]::Red
                    }
                    else {
                        if($pourcentage -gt 50)
                        {
                            $childNode4.ForeColor = [System.Drawing.Color]::Green
                        }else{$childNode4.ForeColor = [System.Drawing.Color]::Blue}
                    }
                }
            }
        }
    }
}
$rootNode.Expand() # Dérouler le nœud racine

# Ajouter le TreeView à la fenêtre
$form.Controls.Add($treeView)
# Afficher la fenêtre
$form.ShowDialog()
}

Start-Job -ScriptBlock $display -ArgumentList $tableauStats