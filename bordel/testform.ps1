#[System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework") | Out-Null

# Chargez le contenu du fichier XAML (remplacez le chemin par le vôtre)
$XamlContent = Get-Content -Path "C:\Users\gunsa\Desktop\Sc_Powershell\bordel\testform.xaml" -Raw

# Créez la fenêtre à partir du XAML
$Window = [Windows.Markup.XamlReader]::Load([System.Xml.XmlReader]::Create([System.IO.StringReader]::new($XamlContent)))


# Affichez la fenêtre
$Window.ShowDialog()

