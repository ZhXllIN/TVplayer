param([ValidateSet('A','B')][string]$Channel='A')
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms
$ErrorActionPreference='Stop'
$cache=Join-Path $PSScriptRoot "PlayerData\$Channel"
[void][IO.Directory]::CreateDirectory($cache)
$pages=@()
$window=New-Object Windows.Window
$window.Title="广告播放控制 · $Channel"
$window.Background='#F2F5F8'
$window.FontFamily='Microsoft YaHei UI'
$window.FontSize=14
$window.Foreground='#182B41'
$window.Width=580
$window.Height=790
$panel=New-Object Windows.Controls.StackPanel
$panel.Margin=20
$scroll=New-Object Windows.Controls.ScrollViewer
$scroll.Content=$panel
$window.Content=$scroll
function Add-Control($type,$label){
 $c=New-Object "Windows.Controls.$type"
  $c.Margin='0,3,0,3'
 if($type -in 'TextBox','Button','ComboBox'){$c.Padding='9,5,9,5'}
 if($type -eq 'Button'){$c.Cursor='Hand'}
 if($label){$c.Content=$label}
 [void]$panel.Children.Add($c)
 return $c
}
$heading=Add-Control Label "输出 $Channel   /   播放列表"
$heading.FontSize=22
$list=Add-Control ListBox
$list.Height=150
$add=Add-Control Button '添加素材…'
$remove=Add-Control Button '移除选中项'
$label=Add-Control Label '目标显示器'
$screen=Add-Control ComboBox
$monitors=[Windows.Forms.Screen]::AllScreens
foreach($m in $monitors){[void]$screen.Items.Add($m.DeviceName)}
$screen.SelectedIndex=if($Channel -eq 'B'){$monitors.Count-1}else{0}
$single=Add-Control CheckBox '单项播放（固定当前页或循环当前视频）'
$label=Add-Control Label '每页停留秒数'
$duration=Add-Control TextBox
$duration.Text='20'
$label=Add-Control Label '每日播放时段（如 08:00-22:00，留空为全天）'
$hours=Add-Control TextBox
$label=Add-Control Label '每日休息时段（如 12:00-13:00，留空为无休息）'
$rest=Add-Control TextBox
$auto=Add-Control CheckBox 'Windows 登录后自动启动此路'
$play=Add-Control Button '保存设置并开始 / 等待定时播放'
$stop=Add-Control Button '停止此路播放'
$play.Background=if($Channel -eq 'A'){'#174B60'}else{'#334674'}
$play.Foreground='White'
$play.FontWeight='SemiBold'
$output=New-Object Windows.Window
$output.WindowStyle='None'
$output.Background='Black'
$output.ResizeMode='NoResize'
$timer=New-Object Windows.Threading.DispatcherTimer
Add-Type -Path (Join-Path $PSScriptRoot 'tools\mpv\PortableVideo.cs')
[PortableVideo]::Load((Join-Path $PSScriptRoot 'tools\mpv\libmpv-2.dll'))
$videoClock=New-Object Windows.Threading.DispatcherTimer
$videoClock.Interval=[timespan]::FromMilliseconds(200)
function Stop-Video {
 $videoClock.Stop()
 if($script:video){

  $script:video.Dispose()
  $script:video=$null
 }
}
function Halt {
 $script:armed=$false
 $timer.Stop()
 Stop-Video
 $output.Content=$null
 $output.Hide()
}
function Show-Item {
 $timer.Stop()
 $path=$pages[$script:index]
 Stop-Video
 if([IO.Path]::GetExtension($path) -match '^\.(mp4|wmv|avi|mov|m4v|mkv|webm|ts|mpg|mpeg)$'){
  $output.Content=$null
  $handle=([Windows.Interop.WindowInteropHelper]::new($output)).Handle
  $script:video=[PortableVideo]::new($path,$handle.ToInt64())
  $videoClock.Start()
 }else{
  $img=New-Object Windows.Controls.Image
  $img.Source=[Windows.Media.Imaging.BitmapImage]::new([uri]$path)
  $output.Content=$img
  if(!$single.IsChecked){$timer.Start()}
 }
}
function Advance {
 if(!$single.IsChecked){$script:index=($script:index+1)%$pages.Count}
 try{Show-Item}catch{Halt;[void][Windows.MessageBox]::Show($_.Exception.Message)}
}
function Parse-Range($value){
 if(!$value.Trim()){return}
 if($value.Trim() -notmatch '^([01]\d|2[0-3]):([0-5]\d)\s*-\s*([01]\d|2[0-3]):([0-5]\d)$'){throw '时段格式应为 08:00-22:00'}
 $start=60*[int]$Matches[1]+[int]$Matches[2]
 $end=60*[int]$Matches[3]+[int]$Matches[4]
 if($start -eq $end){throw '开始和结束时间须不同'}
 $start
 $end
}
function In-Range($minute,$range){
 if($range[0] -lt $range[1]){return $minute -ge $range[0] -and $minute -lt $range[1]}
 return $minute -ge $range[0] -or $minute -lt $range[1]
}
$videoClock.Add_Tick({
 if(!$script:video){return}
 $code=$script:video.Poll()
 if($code){
  Stop-Video
  if($code -lt 0){Halt;[void][Windows.MessageBox]::Show('视频播放失败，请检查素材。')}else{Advance}
 }
})
$timer.Add_Tick({Advance})
$output.Add_KeyDown({if($_.Key -eq 'Escape'){Halt}})
$output.Add_Closing({if(!$script:closing){$_.Cancel=$true;Halt}})
$add.Add_Click({
 $dlg=New-Object Microsoft.Win32.OpenFileDialog
 $dlg.Multiselect=$true
 $dlg.Filter='支持的素材|*.png;*.jpg;*.jpeg;*.bmp;*.mp4;*.wmv;*.avi;*.mov;*.m4v;*.mkv;*.webm;*.ts;*.mpg;*.mpeg;*.pdf;*.ppt;*.pptx'
 if(!$dlg.ShowDialog()){return}
 Halt
 foreach($file in $dlg.FileNames){
  try{
   $items=@($file)
   if($file -match '\.(pdf|pptx?)$'){
    $dir=Join-Path $cache ([guid]::NewGuid())
    [void](mkdir $dir)
    $pdf=$file
    if($file -match '\.pptx?$'){
     $profile=([uri](Join-Path $dir 'profile')).AbsoluteUri
     & (Join-Path $PSScriptRoot 'tools\LibreOffice\program\soffice.com') "-env:UserInstallation=$profile" --headless --convert-to 'pdf:impress_pdf_Export' --outdir $dir $file
     $pdf=Join-Path $dir ([IO.Path]::GetFileNameWithoutExtension($file)+'.pdf')
     if($LASTEXITCODE -or !(Test-Path -LiteralPath $pdf)){throw '演示文稿转换失败，请检查文件是否损坏或加密。'}
    }
    & (Join-Path $PSScriptRoot 'tools\poppler\bin\pdftoppm.exe') -scale-to 1920 -png $pdf (Join-Path $dir page)
    if($LASTEXITCODE){throw 'PDF 转换失败'}
    $items=@(Get-ChildItem $dir -Filter *.png | Sort-Object {[int]([regex]::Match($_.BaseName,'\d+$').Value)} | ForEach-Object FullName)
    if(!$items.Count){throw '文件没有可播放的页'}
   }
   if($file -notmatch '\.(pdf|pptx?)$'){
    $target=Join-Path $cache (([guid]::NewGuid()).ToString()+[IO.Path]::GetExtension($file))
    Copy-Item -LiteralPath $file -Destination $target
    $items=@($target)
   }
   $n=0
   foreach($item in $items){
    $n++
    $name=[IO.Path]::GetFileName($file)
    if($items.Count -gt 1){$name+=" · 第 $n 页"}
    [void]$list.Items.Add($name)
    $script:pages+=@($item)
   }
  }catch{[void][Windows.MessageBox]::Show("$file`n$($_.Exception.Message)")}
 }
})
$remove.Add_Click({
 $i=$list.SelectedIndex
 if($i -ge 0){Halt;$list.Items.RemoveAt($i);$script:pages=@(for($j=0;$j -lt $pages.Count;$j++){if($j -ne $i){$pages[$j]}})}
})
$playerPath=$PSCommandPath
$config=Join-Path $cache 'settings.json'
function Apply-Schedule {
 if(!$script:armed){return}
 $now=Get-Date
 $minute=$now.Hour*60+$now.Minute
 $allowed=(!$script:playRange -or (In-Range $minute $script:playRange)) -and (!$script:restRange -or !(In-Range $minute $script:restRange))
 if(!$allowed){
  if($output.IsVisible){Halt;$script:armed=$true}
  return
 }
 if($output.IsVisible){return}
 $output.WindowState='Normal'
 $output.Show()
 $handle=([Windows.Interop.WindowInteropHelper]::new($output)).Handle
 $bounds=$monitors[$screen.SelectedIndex].Bounds
 [void][DisplayPosition]::SetWindowPos($handle,[intptr]::Zero,$bounds.X,$bounds.Y,$bounds.Width,$bounds.Height,64)
 $output.Activate()
 Show-Item
}
function Arm {
 if(!$pages.Count){throw '请先添加素材'}
 $script:playRange=@(Parse-Range $hours.Text)
 $script:restRange=@(Parse-Range $rest.Text)
 $seconds=[int]$duration.Text
 if($seconds -lt 1){throw '停留时间至少为 1 秒'}
 $timer.Interval=[timespan]::FromSeconds($seconds)
 $script:index=[math]::Max(0,$list.SelectedIndex)
 $script:armed=$true
}
$play.Add_Click({
 try{
  Halt
  Arm
  $portable=@(foreach($path in $pages){
   if($path.StartsWith($cache+'\',[StringComparison]::OrdinalIgnoreCase)){$path.Substring($cache.Length+1)}
   else{
    $target=([guid]::NewGuid()).ToString()+[IO.Path]::GetExtension($path)
    Copy-Item -LiteralPath $path -Destination (Join-Path $cache $target)
    $target
   }
  })
  $state=@{pages=$portable;names=@($list.Items);screen=$screen.SelectedItem;seconds=$duration.Text;hours=$hours.Text;rest=$rest.Text;single=[bool]$single.IsChecked;index=$script:index;auto=[bool]$auto.IsChecked}
  $state | ConvertTo-Json -Depth 4 | Set-Content "$config.tmp" -Encoding UTF8
  if(Test-Path $config){[IO.File]::Replace("$config.tmp",$config,"$config.bak")}else{[IO.File]::Move("$config.tmp",$config)}
  $link=Join-Path ([Environment]::GetFolderPath('Startup')) "Touping-$Channel.lnk"
  if($auto.IsChecked){
   $shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($link)
   $shortcut.TargetPath="$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
   $shortcut.Arguments="-NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$playerPath`" $Channel"
   $shortcut.Save()
  }elseif(Test-Path $link){Remove-Item -LiteralPath $link}
  Apply-Schedule
 }catch{Halt;[void][Windows.MessageBox]::Show($_.Exception.Message)}
})
Add-Type 'using System; using System.Runtime.InteropServices; public class DisplayPosition { [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after,int x,int y,int w,int height,uint flags); }'
$stop.Add_Click({Halt})
$window.Add_Closed({$script:closing=$true;Halt;$output.Close()})
$clock=New-Object Windows.Threading.DispatcherTimer
$clock.Interval=[timespan]::FromSeconds(1)
$clock.Add_Tick({try{Apply-Schedule}catch{Halt;[void][Windows.MessageBox]::Show($_.Exception.Message)}})
$window.Add_ContentRendered({
 if(Test-Path $config){
  try{
   $state=Get-Content $config -Raw | ConvertFrom-Json
   $script:pages=@(foreach($path in $state.pages){if([IO.Path]::IsPathRooted($path)){$path}else{Join-Path $cache $path}})
   foreach($name in $state.names){[void]$list.Items.Add($name)}
   if($screen.Items.Contains($state.screen)){$screen.SelectedItem=$state.screen}
   $list.SelectedIndex=$state.index
   $hours.Text=$state.hours
   $rest.Text=$state.rest
   $duration.Text=$state.seconds
   $single.IsChecked=$state.single
   $auto.IsChecked=$state.auto
   if($state.auto){Arm}
  }catch{Halt;[void][Windows.MessageBox]::Show($_.Exception.Message)}
 }
 $clock.Start()
})
[void]$window.ShowDialog()
$clock.Stop()





