$location= "D:\Temp\Popquiz\#2"
$mp3 = Get-ChildItem -File $location


$mp3|select -First 300|% {

    ffmpeg -t 20 -i "$($_.FullName)" -af "afade=t=in:ss=0:d=2" ($location + "\output2\" + $_.BaseName + "20Sec.mp3")
}



$location= "D:\Temp\Popquiz\#2\output2"
$mp3 = Get-ChildItem -File $location

$i = 0
$mp3|select -First 800 |% {
$i++
$_.BaseName

    #ffmpeg  -r 1/5 -i  "C:\Users\Studio\Pictures\Big-Music-Quiz.jpg" -i "$($_.FullName)" -c:v libx264 -vf fps=25 -pix_fmt yuv420p "D:\Projecten\Audio\Daniel\Projecten\Lopend\2019\Music Quiz\Export\1\output\$($_.BaseName).mp4"
    ffmpeg -framerate 1 -i "C:\Users\Studio\Pictures\Big-Music-Quiz.jpg" -i "$($_.FullName)" -c:v copy -c:a aac -strict experimental ($location + "\video2\#2 Music Quiz "+$i + " " + ($_.BaseName.replace('20Sec','')) + ".mp4")
    #ffmpeg -loop 1 -framerate 1 -i "C:\Users\Studio\Pictures\Big-Music-Quiz.jpg" -i "$($_.FullName)" -c:v libx264 -preset veryslow -crf 0 -c:a copy -shortest -threads 2 "D:\Projecten\Audio\Daniel\Projecten\Lopend\2019\Music Quiz\Export\1\output\$($_.BaseName).mp4"

    #ffmpeg -loop 1 -i "C:\Users\Studio\Pictures\Big-Music-Quiz.jpg" -i "$($_.FullName)" -c:a copy -c:v libx264 -shortest "D:\Projecten\Audio\Daniel\Projecten\Lopend\2019\Music Quiz\Export\1\output\$($_.BaseName).mp4"

}
