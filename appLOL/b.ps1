# Créez une fenêtre Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "Exemple de TreeView avec images"
$form.Size = New-Object Drawing.Size(400, 300)

# Créez un contrôle TreeView
$treeView = New-Object Windows.Forms.TreeView
$treeView.Dock = [System.Windows.Forms.DockStyle]::Fill

# Créez un objet ImageList et ajoutez des images
$imageList = New-Object Windows.Forms.ImageList
$imageList.ImageSize = New-Object Drawing.Size(16, 16)  # Taille des images (16x16 pixels)

# Ajoutez les images à l'objet ImageList
$imageList.Images.Add((New-Object Drawing.Bitmap ".\appLOL\test.jpg"))
$imageList.Images.Add((New-Object Drawing.Bitmap ".\appLOL\test.jpg"))

# Associez l'objet ImageList au TreeView
$treeView.ImageList = $imageList

# Ajoutez des nœuds avec des images
$rootNode = $treeView.Nodes.Add("Racine", 0)  # L'index 0 correspond à la première image
$childNode = $rootNode.Nodes.Add("Enfant 1", 1)  # L'index 1 correspond à la deuxième image

# Ajoutez le TreeView à la fenêtre
$form.Controls.Add($treeView)

# Affichez la fenêtre
$form.ShowDialog()


# Créer une fenêtre Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "Exemple de TreeView avec images"
$form.Size = New-Object Drawing.Size(600, 400)  # Ajuster la taille de la fenêtre

# Créer un contrôle TreeView
$treeView = New-Object Windows.Forms.TreeView
$treeView.Dock = [System.Windows.Forms.DockStyle]::Fill

# Créer un objet ImageList et ajouter des images (comme dans l'exemple précédent)

# Associer l'objet ImageList au TreeView (comme dans l'exemple précédent)

# Ajouter des nœuds avec des images (comme dans l'exemple précédent)

# Ajouter le TreeView à la fenêtre
$form.Controls.Add($treeView)

# Ajuster la taille de la police et la hauteur des nœuds
$treeView.Font = New-Object Drawing.Font("Arial", 12, [Drawing.FontStyle]::Regular)  # Augmenter la taille de la police
$treeView.ItemHeight = 30  # Augmenter la hauteur des nœuds

# Afficher la fenêtre
$form.ShowDialog()



