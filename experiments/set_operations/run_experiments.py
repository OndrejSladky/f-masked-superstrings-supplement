import subprocess
import os

msi_path = "../../fmsi/fmsi"
camel_path = "../../kmercamel/kmercamel"
cbl_path_pref = "../../CBL/target.k_"
cbl_path_suff = "/release/examples/cbl"
cbl_directory = "../../CBL"
file1="C.briggsae.fna"
file2="C.elegans.fna"

def run_subprocess(args, offset=0):
    print(f"running {args}")
    proc = subprocess.Popen(["/usr/bin/time", "-v"] + args, stderr=subprocess.PIPE)
    output = proc.stderr.read()
    print(f"output of time on {args} is {output}")
    output = output.split(b"\n")
    time = float(output[1 + offset].strip().split()[3])
    memory = int(output[9 + offset].strip().split()[5])
    return time, memory

def jellycount(file1, k):
    args = ["jellyfish", "count", "-m", str(k), "-s", "100M",  "-o", f"{file1}.jf" ,"-C", file1]
    print(f"running {args}")
    subprocess.run(args)
    with open(f"{file1}_stats.txt", "w") as f:
        subprocess.run(["jellyfish", "stats", f"{file1}.jf"], stdout=f)
    with open(f"{file1}_stats.txt", "r") as f:
        for _ in range(4):
            key, value = f.readline().split()
            if key == "Distinct:":
                print(f" ... found {value} distinct k-mers")
                return int(value)


def count_kmers(file1, file2, k):
    count1 = jellycount(file1, k)
    count2 = jellycount(file2, k)
    subprocess.run(["jellyfish", "merge", "-o", "merged.jf", f"{file1}.jf", f"{file2}.jf"])

    union = 0
    with open(f"merged_stats.txt", "w") as f:
        subprocess.run(["jellyfish", "stats", f"merged.jf"], stdout=f)
    with open(f"merged_stats.txt", "r") as f:
        for _ in range(4):
            key, value = f.readline().split()
            if key == "Distinct:":
                union = int(value)

    intersection = count1 + count2 - union
    difference = union - intersection

    return {
        "1": count1,
        "2": count2,
        "union": union,
        "intersection": intersection,
        "difference": difference
    }



def superstring_params(file: str):
    length = 0
    runs = 0
    ones = 0
    with open(file, "r") as f:
        header = f.readline()
        ms = f.readline()
        for i in range(len(ms)):
            length += 1
            if ms[i] in "ACGT":
                ones += 1
                if i == 0 or ms[i - 1] in "acgt":
                    runs += 1
    return length, runs, ones




def measure(file1_orig: str, file2_orig: str, k: int, function: str):
    result = "result.fa"
    file1 = file1_orig + ".ms.fa"
    file2 = file2_orig + ".ms.fa"

    placeholder_kmer = "A" * k
    query_file = f"query.{k}.txt"
    with open(query_file, "w") as f:
        f.write(placeholder_kmer)

    run_subprocess([camel_path, "-p", file1_orig, "-k", str(k), "-o", file1, "-c"])
    print("ran camel on file1")
    len1, runs1, ones1 = superstring_params(file1)
    run_subprocess([camel_path, "-p", file2_orig, "-k", str(k), "-o", file2, "-c"])
    print("ran camel on file2")
    len2, runs2, ones2 = superstring_params(file2)

    time_indexing1, _ = run_subprocess([msi_path, "index", "-p", file1, "-k", str(k)], 5)
    _, memory_1_query = run_subprocess([msi_path, "query", "-p", file1, "-k", str(k), "-q", query_file, "-s"], 0)
    print("constructed index on file1")
    time_indexing2, _ = run_subprocess([msi_path, "index", "-p", file2, "-k", str(k)], 5)
    _, memory_2_query = run_subprocess([msi_path, "query", "-p", file2, "-k", str(k), "-q", query_file, "-s"], 0)
    print("constructed index on file2")

    time_merge, _ = run_subprocess([msi_path, "merge", "-p", file1, "-p", file2,  "-r", result], 3)
    _, memory_merge_query = run_subprocess([msi_path, "query", "-p", result, "-k", str(k), "-q", query_file, "-f", function, "-s"], 0)
    print("ran merge")

    time_normalize, _ = run_subprocess([msi_path, "normalize", "-p", result, "-k", str(k), "-f", function], 4)
    _, memory_normalize_query = run_subprocess([msi_path, "query", "-p", result, "-k", str(k), "-q", query_file, "-s"], 0)
    print("ran normalize")

    subprocess.run([msi_path, "export", "-p", result], stdout=open(result, "w"))
    len_res, runs_res, ones_res = superstring_params(result)

    return time_indexing1, time_indexing2, time_merge, time_normalize, memory_1_query, memory_2_query, memory_merge_query, memory_normalize_query, len1, len2, len_res, runs1, runs2, runs_res, ones1, ones2, ones_res

# with open("results-test.csv", "w") as output:
with open("results-roundworms.csv", "w") as output:
    output.write("dataset1,dataset2,k,operation,indexing time 1(s),indexing time 2(s),merge time(s),normalization time(s),set 1 query memory(kB),set 2 query memory(kB),merge query memory(kB),normalization query memory(kB),ms 1 length,ms 2 length,result ms length,ms 1 runs,ms 2 runs,result ms runs,ms 1 ones,ms 2 ones,result ms ones,kmers1,kmers2,kmersRes\n")

    K_VALS = list(range(17, 23, 2))
    K_VALS.append(31)
    K_VALS = [15]
    for k in K_VALS:
        print(f"Running k={k}")
        kmers = count_kmers(file1, file2, k)
        for op, f in [("union", "or"), ("difference", "xor"), ("intersection", "2-2")]:
                time_indexing1, time_indexing2, time_merge, time_normalize, memory_1_query, memory_2_query, memory_merge_query, memory_normalize_query, len1, len2, len_res, runs1, runs2, runs_res, ones1, ones2, ones_res = measure(file1, file2, k, f)
                output.write(f"{file1},{file2},{k},{op},{time_indexing1},{time_indexing2},{time_merge},{time_normalize},{memory_1_query},{memory_2_query},{memory_merge_query},{memory_normalize_query},{len1},{len2},{len_res},{runs1},{runs2},{runs_res},{ones1},{ones2},{ones_res},{kmers['1']},{kmers['2']},{kmers[op]}\n")



