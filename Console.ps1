$ErrorActionPreference='Stop'
Add-Type -AssemblyName PresentationFramework
$root=$PSScriptRoot
$ui=[xml]@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="双屏广告播放台" Width="660" Height="380" MinWidth="510" MinHeight="340" WindowStartupLocation="CenterScreen" Background="#F2F5F8" FontFamily="Microsoft YaHei UI" FontSize="15">
 <DockPanel Margin="28">
  <StackPanel DockPanel.Dock="Top" Margin="0,0,0,24"><TextBlock Text="双屏广告播放台" FontSize="30" FontWeight="SemiBold" Foreground="#182B41"/><TextBlock Text="选择输出通道，管理该电视的素材和播放时段。" Foreground="#526678" Margin="0,8,0,0"/></StackPanel>
  <UniformGrid Columns="2">
   <Button Name="A" Margin="0,0,8,0" Background="#174B60" Foreground="White" BorderThickness="0" Cursor="Hand"><StackPanel><TextBlock Text="输出 A" FontSize="28" FontWeight="SemiBold"/><TextBlock Text="打开播放控制  →" Margin="0,14,0,0"/></StackPanel></Button>
   <Button Name="B" Margin="8,0,0,0" Background="#334674" Foreground="White" BorderThickness="0" Cursor="Hand"><StackPanel><TextBlock Text="输出 B" FontSize="28" FontWeight="SemiBold"/><TextBlock Text="打开播放控制  →" Margin="0,14,0,0"/></StackPanel></Button>
  </UniformGrid>
 </DockPanel>
</Window>
"@
$window=[Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($ui))
function Open-Channel($channel){
 $title="广告播放控制 · $channel"
 $shell=New-Object -ComObject WScript.Shell
 if($shell.AppActivate($title)){return}
 $file=Join-Path $root 'Player.ps1'
 Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$file`" $channel"
}
foreach($name in 'A','B'){$window.FindName($name).Add_Click({Open-Channel $this.Name})}
[void]$window.ShowDialog()
