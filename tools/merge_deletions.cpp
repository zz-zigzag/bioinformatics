#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <math.h>
#include <sys/stat.h>


#define PACKAGE_VERSION "0.0.1"

using namespace std;

typedef struct
{
    char call_chrom[100];
    int call_brk1, call_brk2;
}call_var;

static int usage()
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: merge_deletions (merge deletions by breakpoint\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   merge_deletions [option] <in_data> <out_data>\n");
    fprintf(stderr, "         The input format is [chrom start end] and sorted by chrom and start\n");
    fprintf(stderr, "Options: -c INT   cutoff used to decide two breakpoint are same.[5]\n");
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


int main(int argc, char* argv[])
{
    char c;
    int cutoff = 5;
    while((c = getopt(argc, argv, "c:")) != EOF) {
        switch(c) {
            case 'c': cutoff = atoi(optarg); break;
        }
    }
    if(argc - optind != 2)
        return usage();

    FILE *fpin, *fpout;
    openFile(&fpin, argv[optind], "r");
    openFile(&fpout, argv[optind+1], "w");
    char chrom[100], preChrom[100];
    int start, end, preStart, preEnd;
    fscanf(fpin, "%s%d%d", chrom, &start, &end);
    fprintf(fpout, "%s\t%d\t%d\n", chrom, start, end);
    strcpy(preChrom, chrom);
    preStart = start;
    preEnd = end;

    int cnt =  1, sameCnt = 0;
    while(fscanf(fpin, "%s%d%d", chrom, &start, &end) !=EOF){
        if (abs(start - preStart) <= cutoff && abs(end - preEnd) <= cutoff && !strcmp(chrom, preChrom))
            sameCnt++;
        else fprintf(fpout, "%s\t%d\t%d\n", chrom, start, end);
        strcpy(preChrom, chrom);
        preStart = start;
        preEnd = end;
        cnt++;
    }
    fprintf(stderr, "[merge_deletions] %s: Total %d deletions, %d same deletions\n", argv[optind], cnt, sameCnt);
    return 0;
}









