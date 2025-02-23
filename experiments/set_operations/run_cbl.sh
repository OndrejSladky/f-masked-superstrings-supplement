if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <fasta1> <fasta2> <k>"
    exit 1
fi

k=$3
g1=$1
g2=$2

mkdir -p CBL-logs

cbl="../../CBL/target.k_$k/release/examples/cbl"
echo "running CBL at $cbl"

echo " ===== building CBL index for $g1 ===== "
../../scripts/benchmark.py --log "CBL-logs/CBL.build.k$k.$g1.log" "$cbl build -c -o $g1.cbl $g1"
echo " ===== building CBL index for $g2 ===== "
../../scripts/benchmark.py --log "CBL-logs/CBL.build.k$k.$g2.log" "$cbl build -c -o $g2.cbl $g2"

query="query.$k.fa"

echo " ===== running queries on original indexes ===== "
../../scripts/benchmark.py --log "CBL-logs/CBL.query.k$k.$g1.log" "$cbl query $g1.cbl $query"
../../scripts/benchmark.py --log "CBL-logs/CBL.query.k$k.$g2.log" "$cbl query $g2.cbl $query"


echo " ===== computing union ===== "
../../scripts/benchmark.py --log "CBL-logs/CBL.union.k$k.$g1.$g2.log" "$cbl merge -o $g1.union.$g2.cbl $g1.cbl $g2.cbl"
../../scripts/benchmark.py --log "CBL-logs/CBL.query.k$k.$g1.union.$g2.log" "$cbl query $g1.union.$g2.cbl $query"

echo " ===== computing intersection ===== "
../../scripts/benchmark.py --log "CBL-logs/CBL.inter.k$k.$g1.$g2.log" "$cbl inter -o $g1.inter.$g2.cbl $g1.cbl $g2.cbl"
../../scripts/benchmark.py --log "CBL-logs/CBL.query.k$k.$g1.inter.$g2.log" "$cbl query $g1.inter.$g2.cbl $query"

echo " ===== computing sym. difference ===== "
../../scripts/benchmark.py --log "CBL-logs/CBL.sym-diff.k$k.$g1.$g2.log" "$cbl sym-diff -o $g1.sym-diff.$g2.cbl $g1.cbl $g2.cbl"
../../scripts/benchmark.py --log "CBL-logs/CBL.query.k$k.$g1.sym-diff.$g2.log" "$cbl query $g1.sym-diff.$g2.cbl $query"
