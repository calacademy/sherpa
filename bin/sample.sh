cat $1 | awk 'BEGIN{srand();}{print rand()"\t"$0}' | sort -k1 -n | cut -f2- | head -n $2 > $1.shuffled
