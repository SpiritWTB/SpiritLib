#Requires -Version 5.1 -PSEdition Desktop
Set-StrictMode -Version Latest

# Installer script created by Alyx (binary#3615)

<#┌─────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Initialization                                                                              │
  └─────────────────────────────────────────────────────────────────────────────────────────────┘#>
	<#┌─────────────────────────────────────────────┐
	  │ Add Windows Forms                           │
	  └─────────────────────────────────────────────┘#>
		Add-Type -AssemblyName System.Windows.Forms
		[Windows.Forms.Application]::EnableVisualStyles()

	<#┌─────────────────────────────────────────────┐
	  │ Declare Functions                           │
	  └─────────────────────────────────────────────┘#>
		Function Expand-World($Path) {
			$InputStream = [IO.File]::OpenRead($Path)
			$OutputStream = New-Object -TypeName IO.MemoryStream

			$GZipStream = New-Object -TypeName IO.Compression.GZipStream -ArgumentList $InputStream, ([IO.Compression.CompressionMode]::Decompress)
			$GZipStream.CopyTo($OutputStream)

			$GZipStream.Close()
			$OutputStream.Close()
			$InputStream.Close()

			Return [Text.Encoding]::UTF8.GetString($OutputStream.ToArray())
		}

		Function Compress-World($Path, $Data) {
			$Bytes = [Text.Encoding]::UTF8.GetBytes($Data)
			$OutputStream = New-Object -TypeName IO.MemoryStream

			$GZipStream = New-Object -TypeName IO.Compression.GZipStream -ArgumentList $OutputStream, ([IO.Compression.CompressionMode]::Compress)
			$GZipStream.Write($Bytes, 0, $Bytes.Length)

			$GZipStream.Close()
			$OutputStream.Close()

			[IO.File]::WriteAllBytes($Path, $OutputStream.ToArray())
		}

		Function Get-VacantWTBIndex() {
			$Measured = $WorldData.AllWTBOData | Measure-Object -Property "WTBIndex" -Maximum
			Return $Measured.Maximum + 1
		}

		Function Add-CorePart() {
			ForEach ($Part in $WorldData.AllWTBOData) {
				ForEach ($Component in $Part.Components) {
					If ($Component.Name -eq "Script") {
						ForEach ($Property in $Component.Properties) {
							If ($Property.Name -eq "Script" -and $Property.dataString -eq "SpiritLib") {
								Return
							}
						}
					}
				}
			}

			$WTBIndex = Get-VacantWTBIndex
			$CorePartJSON = '{"Components":[{"$type":"WorldComponent, Assembly-CSharp","Name":"World","Properties":[{"$type":"PropertyName, Assembly-CSharp","Name":"Name","dataType":"string","dataString":"SpiritLib"},{"$type":"PropertyObjectType, Assembly-CSharp","Name":"ObjectType","dataType":"string","dataString":"Part"},{"$type":"PropertyParent, Assembly-CSharp","editorDataIntView":0,"Name":"Parent","dataType":"int","dataInt":0}],"PropertiesByName":{},"IsAlwaysSameContent":true},{"$type":"TransformComponent, Assembly-CSharp","Name":"Transform","Properties":[{"$type":"PropertyCanCollide, Assembly-CSharp","Name":"CanCollide","dataType":"bool","dataBool":false},{"$type":"PropertyHasPhysics, Assembly-CSharp","Name":"HasPhysics","dataType":"bool","dataBool":false},{"$type":"PropertySize, Assembly-CSharp","Name":"Size","dataType":"Vector3","dataVector3":{"x":1,"y":1,"z":1}},{"$type":"PropertyPosition, Assembly-CSharp","Name":"Position","dataType":"Vector3","dataVector3":{"x":0,"y":0,"z":0}},{"$type":"PropertyRotation, Assembly-CSharp","Name":"Rotation","dataType":"Vector3","dataVector3":{"x":0,"y":0,"z":0}}],"PropertiesByName":{},"IsAlwaysSameContent":true},{"$type":"RendererComponent, Assembly-CSharp","Name":"Renderer","Properties":[{"$type":"PropertyColor, Assembly-CSharp","Name":"Color","dataType":"string","dataString":"00000000"},{"$type":"PropertyMaterial, Assembly-CSharp","Name":"Material","dataType":"int","dataInt":0},{"$type":"PropertyVisible, Assembly-CSharp","Name":"Visible","dataType":"bool","dataBool":false},{"$type":"PropertyTransparency, Assembly-CSharp","Name":"Transparency","dataType":"string","dataString":"0"},{"$type":"PropertyPartType, Assembly-CSharp","Name":"PartType","dataType":"int","dataInt":0},{"$type":"PropertyRounded, Assembly-CSharp","Name":"Rounded","dataType":"bool","dataBool":false},{"$type":"PropertyShadows, Assembly-CSharp","Name":"Shadows","dataType":"bool","dataBool":false}],"PropertiesByName":{},"IsAlwaysSameContent":true},{"$type":"ScriptComponent, Assembly-CSharp","Name":"Script","Properties":[{"$type":"PropertyScript, Assembly-CSharp","Name":"Script","dataType":"string","dataString":"SpiritLib"}],"PropertiesByName":{},"IsAlwaysSameContent":true}],"WTBIndex":' + $WTBIndex + ',"netID":0}'
			$WorldData.AllWTBOData += ConvertFrom-Json -InputObject $CorePartJSON
		}


<#┌─────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Install SpiritLib                                                                           │
  └─────────────────────────────────────────────────────────────────────────────────────────────┘#>
	<#┌─────────────────────────────────────────────┐
	  │ Open World File                             │
	  └─────────────────────────────────────────────┘#>
		$SaveDialog = New-Object -TypeName Windows.Forms.OpenFileDialog
		$SaveDialog.Title = "Import saved world"
		$SaveDialog.Filter = "World to Build Save|*.wtb"
		$SaveDialog.InitialDirectory = [Environment]::GetFolderPath("MyDocuments") + "\World To Build\saves"

		$Caller = New-Object -TypeName Windows.Forms.Form
		$Caller.Location = New-Object -TypeName Drawing.Point -ArgumentList -100, -100
		$Caller.Size = New-Object -TypeName Drawing.Size -ArgumentList 10, 10
		$Caller.StartPosition = [Windows.Forms.FormStartPosition]::Manual
		$Caller.Icon = [Drawing.Icon]::ExtractAssociatedIcon("${PSScriptRoot}\SpiritLib.ico")
		$Caller.TopMost = $true

		$Caller.Add_Shown({
			$Caller.Activate()
			$Caller.DialogResult = $SaveDialog.ShowDialog($Caller)
			$Caller.Close()
		})

		If ($Caller.ShowDialog() -eq "OK") {
			$SelectedWorld = $SaveDialog.FileName
		}
		Else {
			[Windows.Forms.MessageBox]::Show("A world file is required to install SpiritLib.", "SpiritLib Installer", 0, 16) > $null
			Exit
		}

	<#┌─────────────────────────────────────────────┐
	  │ Parse File Contents                         │
	  └─────────────────────────────────────────────┘#>
		$Decompressed = Expand-World $SelectedWorld
		$Sections = $Decompressed -split "\|{3}"

		If ($Sections[0].Substring(0, 1) -ne "{") {
			$Bytes = [Convert]::FromBase64String($Sections[0])
			$Sections[0] = [Text.Encoding]::UTF8.GetString($Bytes)
		}

		$WorldData = ConvertFrom-Json -InputObject $Sections[0]
		$AllScripts = [Ordered] @{}

		If ($Sections.Count -gt 1) {
			ForEach ($Script in ($Sections[1..($Sections.Count - 1)])) {
				$Split = $Script -split "\|{2}"

				If (!([String]::IsNullOrWhitespace($Split[0])) -and !([String]::IsNullOrWhiteSpace($Split[1]))) {
					$Bytes = [Convert]::FromBase64String($Split[0])
					$Title = [Text.Encoding]::UTF8.GetString($Bytes)

					If ($Title -ne "No Script") {
						$Bytes2 = [Convert]::FromBase64String($Split[1])
						$Content = [Text.Encoding]::UTF8.GetString($Bytes2)

						$AllScripts[$Title] = $Content
					}
				}
			}
		}

	<#┌─────────────────────────────────────────────┐
	  │ Insert All Scripts                          │
	  └─────────────────────────────────────────────┘#>
		$ScriptFiles = Get-ChildItem -LiteralPath "${PSScriptRoot}\..\Scripts" -Include "*.lua" -File

		ForEach ($File in $ScriptFiles) {
			$ScriptName = $File.BaseName
			$ScriptContent = Get-Content -LiteralPath $File.FullName -Encoding UTF8 -Raw

			$AllScripts[$ScriptName] = $ScriptContent
		}

		Add-CorePart

	<#┌─────────────────────────────────────────────┐
	  │ Export to Saved World                       │
	  └─────────────────────────────────────────────┘#>
		$Output = ""

		$JSONWorldData = ConvertTo-Json -InputObject $WorldData -Depth 7 -Compress
		$EncodedWorldData = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($JSONWorldData))

		$Output = $Output + $EncodedWorldData

		ForEach ($Script in $AllScripts.GetEnumerator()) {
			$EncodedName = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Script.Name))
			$EncodedContent = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Script.Value))

			$Output += "|||${EncodedName}||${EncodedContent}"
		}

	<#┌─────────────────────────────────────────────┐
	  │ Save World File                             │
	  └─────────────────────────────────────────────┘#>
		$SaveDialog = New-Object -TypeName Windows.Forms.SaveFileDialog
		$SaveDialog.Title = "Export saved world"
		$SaveDialog.Filter = "World to Build Save|*.wtb"
		$SaveDialog.InitialDirectory = [Environment]::GetFolderPath("MyDocuments") + "\World To Build\saves"

		$Caller = New-Object -TypeName Windows.Forms.Form
		$Caller.Location = New-Object -TypeName Drawing.Point -ArgumentList -100, -100
		$Caller.Size = New-Object -TypeName Drawing.Size -ArgumentList 10, 10
		$Caller.StartPosition = [Windows.Forms.FormStartPosition]::Manual
		$Caller.Icon = [Drawing.Icon]::ExtractAssociatedIcon("${PSScriptRoot}\SpiritLib.ico")
		$Caller.TopMost = $true

		$Caller.Add_Shown({
			$Caller.Activate()
			$Caller.DialogResult = $SaveDialog.ShowDialog($Caller)
			$Caller.Close()
		})

		If ($Caller.ShowDialog() -eq "OK") {
			$SavePath = $SaveDialog.FileName
		}
		Else {
			[Windows.Forms.MessageBox]::Show("A save location is required to install SpiritLib.", "SpiritLib Installer", 0, 16) > $null
			Exit
		}

	<#┌─────────────────────────────────────────────┐
	  │ Export to Saved World                       │
	  └─────────────────────────────────────────────┘#>
		Compress-World $SavePath $Output

	<#┌─────────────────────────────────────────────┐
	  │ Finished!                                   │
	  └─────────────────────────────────────────────┘#>
		[Windows.Forms.MessageBox]::Show("Installation successful. Thank you for using SpiritLib! ^_^", "SpiritLib Installer", 0, 64) > $null
		Exit

Pause