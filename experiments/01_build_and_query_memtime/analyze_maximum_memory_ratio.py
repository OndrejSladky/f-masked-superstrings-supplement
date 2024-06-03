# This script returns the min-median-max ratio of given algorithms to FMSI; split on genomes and rates

data = {}

for line in open('99_results/exp_01_build_index_results.kamenac.tsv'):
    if 'num_queries' in line:
        continue
    s = line.strip().split('\t')
    key = s[0] + s[1] + s[4] + '$' + s[2]
    if s[4] == 'local':
        continue
    data[key] = s[11]


for alg in ['cbl', 'sbwt', 'bwa', 'SSHash']:
    print(alg)
    for g in ['escherichia_coli.k32', 'sars-cov-2_pangenome_k32', 'spneumo_pangenome_k32', 'spneumoniae']:
        print(g)
        rates = ['Highly subsampled', 'Subsampled', 'Not subsampled']
        for rate in rates:
            ratios = []
            for key, val in data.items():
                if g in key and alg in key:
                    if rate == 'Highly subsampled' and '0.01' not in key:
                        continue
                    if rate == 'Subsampled' and ('0.' not in key or '0.01' in key):
                        continue
                    if rate == 'Not subsampled' and '0.' in key:
                        continue
                    next_key = key.split('$')[0] + '$' + "FMSIv02"
                    if next_key in data:
                        ratios.append(int(val) / int(data[next_key]))
            if not ratios:
                print(rate +  ": 0-0-0")
                continue
            sorted_data = sorted(ratios)
            sorted_data = [str(x) for x in sorted_data]
            print(rate +  ": " + sorted_data[0] + '-' + sorted_data[len(sorted_data) // 2] + '-' + sorted_data[-1])
        print('---------------------')
    print('=====================')



