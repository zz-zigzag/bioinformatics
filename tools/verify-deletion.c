#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/stat.h>


#define PACKAGE_VERSION "0.1.1"

typedef struct
{
    char call_chrom[100];
    int call_brk1, call_brk2;
}call_var;
typedef struct
{
    char benchmark_chrom[100];
    int benchmark_brk1, benchmark_brk2, benchmark_svlen;
    bool flag_find;
}benchmark_var;
static int usage()
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: verify_deletion (verify the deletion with the benchmark data)\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   verify_deletion [option] <call_data> <benchmark_data> <compare_result>\n");
    fprintf(stderr, "Options: -e FLOAT maximum allowed deviation is -e*sv_length [0.1]\n");
    fprintf(stderr, "         -m INT   maximum allowed deviation [100]\n");
    fprintf(stderr, "Note:    All deletion need to be sorted by coordinate and in one chromosome.\n");
    fprintf(stderr, "         format of call_data: chromosome start end ...\n");
    fprintf(stderr, "         format of benchmark_data: chromosome start end ... \n");
    return 1;
}

void openFile(FILE **file, char *filename, char *type)
{
   if((*file = fopen(filename, type)) == NULL)
   {
       perror(filename);
       exit(1);
   }
   return ;
}

int getFileRowsNumber(char *filename)
{
   char *sys = (char *)malloc(strlen(filename) + 10);
   sprintf(sys,"wc -l %s", filename);
   FILE *fp = popen(sys, "r");
   int n;
   if(fscanf(fp, "%d", &n) != 1)
       exit(1);
   pclose(fp);
   return n;
}
int main(int argc, char* argv[])
{
    char c;
    double percent_diff = 0.1;
    int max_diff = 100;
    while((c = getopt(argc, argv, "e:m:")) != EOF) {
        switch(c) {
            case 'e': percent_diff = atof(optarg); break;
            case 'm': max_diff = atof(optarg); break;
        }
    }
    if(argc - optind != 3)
        return usage();
    FILE *fp_call, *fp_benchmark, *fp_res;
    openFile(&fp_call, argv[optind], "r");
    openFile(&fp_benchmark, argv[optind+1], "r");
    openFile(&fp_res, argv[optind+2], "w");
    char *filename = argv[optind];
    call_var *call;
    benchmark_var *benchmark;
    int call_cnt, benchmark_cnt;
    call_cnt = getFileRowsNumber(argv[optind]);
    benchmark_cnt = getFileRowsNumber(argv[optind+1]);

    call = (call_var *)malloc(call_cnt * sizeof(call_var));
    benchmark = (benchmark_var *)malloc (benchmark_cnt * sizeof(benchmark_var));
    memset(benchmark, 0, benchmark_cnt * sizeof(benchmark_var));

    int i = 0, j = 0;
    char str[1000];
    while(fgets(str, sizeof(str), fp_call) != NULL){
        sscanf(str, "%s%d%d", call[i].call_chrom, &call[i].call_brk1, &call[i].call_brk2);
        i++;
    }
    call_cnt = i;
    while(fgets(str, sizeof(str), fp_benchmark) != NULL) {
        sscanf(str, "%s%d%d", benchmark[j].benchmark_chrom, &benchmark[j].benchmark_brk1, &benchmark[j].benchmark_brk2);
        benchmark[j].benchmark_svlen = benchmark[j].benchmark_brk2 - benchmark[j].benchmark_brk1 - 1;
        j++;
    }
    benchmark_cnt = j;

    int right, call_overlap, benchmark_overlap;
    right = call_overlap = benchmark_overlap = 0;

    j = 0;
    while(j < benchmark_cnt) {
        if(j > 0 && benchmark[j].benchmark_brk1 < benchmark[j-1].benchmark_brk2)
            benchmark_overlap++;
        j++;
    }

    i = j = 0;
    while(i < call_cnt && j < benchmark_cnt)
    {
        /*
        if(i > 0 && call[i].call_brk1 < call[i-1].call_brk2)
        {
            call_overlap++;
            if (pre_right) {
                i++;
                continue;
            }
        }
        */
        int _diff_ = benchmark[j].benchmark_svlen * percent_diff;


        if (_diff_ > max_diff) {
            _diff_ = max_diff;
        }


        if(call[i].call_brk1 < benchmark[j].benchmark_brk1 - _diff_)
        {
        //call 小于 benchmark坐标，则变异不存在。
            fprintf(fp_res, "%s\t%d\t%d\t0\n", call[i].call_chrom, call[i].call_brk1,\
                      call[i].call_brk2);
            i++;
        }
        else if(call[i].call_brk1 > benchmark[j].benchmark_brk1 + _diff_)
        {
        //call 大于 benchmark坐标，bench指针下移。
            j++;
        }
        else
        {
            if(abs(call[i].call_brk2 - benchmark[j].benchmark_brk2) <= _diff_)
            {
                fprintf(fp_res, "%s\t%d\t%d\t1\n", call[i].call_chrom, call[i].call_brk1, call[i].call_brk2);
                right++;
                benchmark[j].flag_find = true;
                i++;
                continue;
            }
            else
                j++;
        }
    }
    while(i < call_cnt)
    {
        fprintf(fp_res, "%s\t%d\t%d\t0\n", call[i].call_chrom, call[i].call_brk1, call[i].call_brk2);
        i++;
    }
    int  bench_c;
    bench_c = benchmark_cnt-benchmark_overlap;
    int benchmark_find_cnt = 0;
    for (i = 0; i < benchmark_cnt; i++) {
        if (benchmark[i].flag_find) benchmark_find_cnt++;
    }
    //fprintf(stdout, "filename\tcall_cnt-call_overlap\tbenchmark_cnt-benchmark_overlap\tright_cnt\tprecision\trecall\n");
    //fprintf(stdout, "%s %d-%d=%d %d-%d=%d %d %.2f %.2f\n", filename, call_cnt, call_overlap, call_c, benchmark_cnt, benchmark_overlap, bench_c, right, right*1.0/(call_c), right*1.0/(bench_c));
    //fprintf(stdout, "%s %d %d %d %.2f %.2f\n", filename, call_c, bench_c, right, right*1.0/(call_c), right*1.0/(bench_c));
    fprintf(stdout, "%s\t%d\t%d\t%d\t%d\t%.3f\t%.3f\n", filename, call_cnt, bench_c, right, benchmark_find_cnt, right*1.0/(call_cnt), benchmark_find_cnt*1.0/(bench_c));

    return 0;
}
