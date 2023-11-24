set terminal png size 400,300
set output "rank.png"
set xlabel "n"
set ylabel "full rank"
plot "rank.out" using 1:2 notitle with linespoints
